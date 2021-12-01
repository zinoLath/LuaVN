local M = {}
MenuSys = M
---ok so there's three types of objects in this thing:
---
---the menu manager: the singular object that serves a sort of base for everything else, and is the 'abstraction' of
---the system from an outside perspective. in  here, you define the main menu that should be played (the first one),
---and the background object
---the parameters you set are: the list of menus that should be instantiated, the background bg, the starting function
---
---the menus: many objects/classes that serve as a way to represent an instance of a menu. basically it just means it
---stores how a menu behaves and looks, storing the classes that are used on the options, and so on
---the parameters you set on this are: which options should be used for each... option, how their positions are defined
---what each option should do when you select it
---
---the options: they're the directly interactable objects. they have a lot of types, and they're in general the hardest
---thing to use lmfao
---the parameters you can set: the function for every event (in, out, select, unselect)
---
---i'm going to use multicast delegate-like stuff for defining the behavior functions, such as what to do when an option
---is selected, or what to do when you go out

M.option = xclass(object)
function M.option:init(manager,menu,tid,id,data)
    self.bound = false
    self.active = false
    self.manager = manager
    self.menu = menu
    self.tid = tid
    self.id = id
    menu.class.obj_init(self,menu)
    self.data = data
    self.class:ctor(data)
end
function M.option:frame()
    task.Do(self)
end
function M.option:ctor(data)

end
function M.option:render()
    RenderText('menu',self.tid,self.x,self.y,0.6,'center')
end
function M.option:_in()
    self.active = true
    SetFieldInTime(self, 60, math.tween.cubicInOut, {'x', self._x}, {'y', self._y})
end
function M.option:_out()
    self.active = false
end
function M.option:_select()
    SetFieldInTime(self, 10, math.tween.cubicInOut, {'x', self._x + 60})
end
function M.option:_unselect()
    SetFieldInTime(self, 10, math.tween.cubicInOut, {'x', self._x})
end
M.option.classname = 'option'


M.menu = xclass(object)
--class, id, extra data
--extra data by default is the delect function, the positions, the font, and so on
M.menu.options = {
    {M.option, 'bald Option'},
    {M.option, 'bald Option2'}
}
function M.menu:init(manager)
    self.manager = manager
    self.objs = {}
    for k,v in ipairs(self.class.options) do
        table.insert(self.objs,New(v[1],manager, self, v[2], k, v[3]))
    end
    self.coroutine = coroutine.create(self.class.coroutine)
    self.key_co = {}
    for k,v in pairs(self.class.key_events) do
        local test = false
        for _k, _v in ipairs(self.class.repeat_keys) do
            Print(string.format("v = %s | _v = %s",tostring(k), tostring(_v)))
            if k == _v then
                test = true
            end
        end
        if test then
            self.key_co[k] = coroutine.create(MenuInputChecker)
        end
    end
    self.selected = 1
end
function M.menu:_in()
    for k,v in ipairs(self.objs) do
        task.New(v, function()
            v.class._in(v)
        end)
    end
end
function M.menu:_out()
end
function M.menu:scroll(vert,hori)
    local t_ids = self.class.options
    local obj = self.objs[self.selected]
    task.New(obj, function()
        obj.class._unselect(obj)
    end)

    if(self.selected + vert > #t_ids) then
        self.selected = 1
    elseif(self.selected + vert < 1) then
        self.selected = #t_ids
    else
        self.selected = self.selected + vert
    end

    local obj2 = self.objs[self.selected]
    task.New(obj2, function()
        obj2.class._select(obj2)
    end)
end
function M.menu:select()
end
M.menu.repeat_keys = {'up', 'down'}
M.menu.key_events = {}
function M.menu.key_events.up(self)
   self.class.scroll(self,1)
end
function M.menu.key_events.down(self)
    self.class.scroll(self,-1)
end
function M.menu.key_events.shoot(self)
end
function M.menu.obj_init(self,menu)
    self._x, self._y = 300, 300 - self.id * 50
end
function M.menu:enter()
    self.class._in(self)
end
function M.menu:coroutine()
    while true do
        for k,v in pairs(self.class.key_events) do
            if self.key_co[k] ~= nil then
                local e, key_status
                e, key_status = coroutine.resume(self.key_co[k],k)
                if key_status then
                    self.class.key_events[k](self)
                end
            else
                if KeyIsPressed(k) then
                    self.class.key_events[k](self)
                end
            end
        end
        coroutine.yield()
    end
end

M.manager = xclass(xobject)
M.manager.name = "DEFAULT_MANAGER"
--{class, id}
M.manager.menus = {
    {M.menu, "main_menu"}
}
M.manager.intro_menu = "main_menu"
function M.manager:init()
    self.menus = {}
    self.bound = false
    self.layer = -1000
    self.stack = stack()
    for k,v in ipairs(self.class.menus) do
        Print(PrintTable(v))
        self.menus[v[2]] = New(v[1],self)
    end
    task.New(self,function()
        self.class.enter_menu(self,self.menus[self.class.intro_menu])
    end)
end
function M.manager:render()
    RenderText('menu',self.class.name,screen.width/2,screen.height/2,1,'center')
end
function M.manager:frame()
    task.Do(self)
    local C, E = coroutine.resume(self.stack[0].coroutine, self.stack[0])
    if(not C)then
        error(E)
    end
end
function M.manager:switch_menu(menu)
    local prev_menu = self.stack[0]
    prev_menu.class._out(prev_menu)
    self.class.enter_menu(self,menu)
end
function M.manager:enter_menu(menu)
    self.stack:push(menu)
    menu.class._in(menu)
end

function MenuInputChecker(name)
    while(true) do
        while(not KeyIsPressed(name))do
            coroutine.yield(false) --return false until the key is pressed
        end
        coroutine.yield(true) --return true once
        for i=0, 30 do
            coroutine.yield(false) --return false for 30 frames
            if (not KeyIsDown(name)) then
                break --if the key is not being held down, break out of for (which will make you consequently restart
            end
        end
        while (KeyIsDown(name)) do
            coroutine.yield(true) -- return true once every 3 frames
            for i=0, 3 do
                coroutine.yield(false) --return false for 3 frames
            end
        end
    end
end
return M