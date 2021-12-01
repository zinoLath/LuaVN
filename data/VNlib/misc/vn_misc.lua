CopyImage('pointer', 'white')
mouse_pointer = xclass(object)
function mouse_pointer:init()
    self.bound = false
    self.img = 'pointer'
    self.group = GROUP_MOUSE
    self.layer = 1000
    self.color = Color(255,255,128,128)
end
function mouse_pointer:frame()
    self.x, self.y = GetMousePosition()
end

local voidfunc = function()  end
clickable = xclass(object)
function clickable:colli()
    if MouseIsPressed(1) then
        local func = self.class.click or voidfunc
        func(self)
    end
    if MouseIsDown(1) then
        local func = self.class.hold or voidfunc
        func(self)
    end
    if not MouseIsPressed(1) and not MouseIsDown(1) then
        local func = self.class.hover or voidfunc
        func(self)
    end
end