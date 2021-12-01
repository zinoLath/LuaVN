local function unpack_nil(tb)
    if tb == nil then
        return nil
    else
        return unpack(tb)
    end
end
---scenes contain the basic events of a thing, up to a splitting point
---they contain a list of servant objects, and the events updates said objects
---such as changing the textbox, and so on
scene = xclass(object)
scene.events = {
    {type = "create_obj", class = textbox, args = {}, id = "textbox"},
    {type = "wait", time = 10},
    {type = "wait", input = 'shoot'},
    {type = "message", text = "how do i insert child?", speaker = "Housama"},
    {type = "message", text = "Just kidding. We don't do that here.", speaker = "Housama"},
    {type = "message", text = "Even if this is the same engine.", speaker = "Housama"},
    {type = "message", text = "But this is a VN system.", speaker = "Housama"},
    {type = "message", text = " Not... whatever THlib is.", speaker = "Housama", add = true},
    {type = "message", text = "Or what 90% of people think LuaSTG is.", speaker = "Housama"},
}
function scene:init()
    self.objs = {}
    local class = self.class
    task.New(self, function()
        for k,v in ipairs(class.events) do
            class.event_types[v.type](self,v)
        end
    end)
end
function scene:frame()
    task.Do(self)
end
function scene:kill()
    for k,v in pairs(self.objs) do
        if v.autodelete ~= false then
            Kill(v)
        end
    end
end
function scene:del()
    for k,v in pairs(self.objs) do
        if v.autodelete ~= false then
            Del(v)
        end
    end
end
scene.event_types = {}
function scene.event_types:create_obj(data)
    self.objs[data.id] = New(data.class, unpack(data.args))
end
function scene.event_types:func(data)
    data.func(self, data)
end
function scene.event_types:message(data)
    self.objs.textbox.class.showMessage(self.objs.textbox, self, data)
end
function scene.event_types:wait(data)
    if data.time then
        task.Wait(data.time)
    else
        while not KeyIsPressed(data.input) do
            task.Wait(1)
        end
    end
end
function scene.event_types:button(data)
    local button_manager = New(multi_choice, data, self)
    task.Wait(1)
    while IsValid(button_manager) do
        task.Wait(1)
    end
end