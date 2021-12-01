CopyImage('button_bg', 'white')
multi_choice = xclass(object)
function multi_choice:init(data,scene)
    self.objs = {}
    self.event = {}
    self.scene = scene
    self.bound = false
    for i,v in ipairs(data.buttons) do
        self.objs[i] = New(single_choice,i,v,self,#data.buttons)
        self.event[i] = v.func
    end
end
function multi_choice:kill()
    for k,v in pairs(self.objs) do
        Kill(v)
    end
end
single_choice = xclass(clickable)
function single_choice:init(id,data,master,maxid)
    self.img = "button_bg"
    self.rect = true
    self.a = 1000
    self.b = 32
    local cx, cy = screen.width/2, screen.height/2
    self.x, self.y = cx,math.lerp(cy+200,cy-10,(id-1)/(maxid-1))
    self.bound = false
    self.group = GROUP_BUTTON
    self.text = data.text
    self.master = master
    self.id = id
    self.scene = self.master.scene
end
function single_choice:frame()
    self.R = 255
end
function single_choice:render()
    local x,y = self.x, self.y
    local a,b = self.a, self.b
    SetImageState(self.img, "", self.color)
    RenderRect(self.img,x-a, x+a, y-b, y+b)

end
function single_choice:hover()
    self.R = 128
end
function single_choice:click()
    self.master.event[self.id](self,self.master,self.scene)
    Kill(self.master)
end
function single_choice:hold()
    self.R = 0
end