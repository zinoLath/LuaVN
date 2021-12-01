Include'VNlib.lua'
--Include'_editor_output.lua' --todo: remove this

stage_init = stage.New('init', true, true)
function stage_init:init()
    New(mouse_pointer)
    local scen = New(scene)
    New(multi_choice,{buttons = {
        {text = "Fuck her", func = function() error("yay this works") end},
        {text = "Fuck her 2 ", func = function() error("yay this works 2 ") end}
    }},scen)
end