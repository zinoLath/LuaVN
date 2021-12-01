LoadImageFromFile('textbox', 'VNlib\\textbox\\textbox.png')
local dialogue_font = BMF:loadFont("philosopher", "VNlib\\font\\philosopher.fnt", "VNlib\\font\\philosopher_0.png")
textbox = xclass(object)
function textbox:init()
    self.img = "textbox"
    local cx, cy = screen.width/2,screen.height/2
    self.bounds = {cx-400,cx+400,100,300}
end
function textbox:render()
    RenderRect(self.img, unpack(self.bounds))
    dialogue_font:render(self.text or "", self.bounds[1]+10, self.bounds[4]-10,0.3,"left", "top")
end
function textbox:showMessage(scene,data)
    self.speaker = data.speaker
    if data.add ~= true then
        self.text_final = data.text
        self.char_counter = 1
    else
        self.char_counter = #self.text_final
        self.text_final = self.text_final .. data.text
    end
    local txt_length = #self.text_final
    task.Wait(5)
    for i=self.char_counter, txt_length do
        self.text = self.text_final:sub(1,i)
        if not KeyIsPressed('shoot') then
            task.Wait(1)
        end
        if not KeyIsPressed('shoot') then
            task.Wait(1)
        end
    end
    task.Wait(1)
    while not KeyIsPressed("shoot") do
        task.Wait(1)
    end
end