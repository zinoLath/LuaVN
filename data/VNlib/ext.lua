gamecontinueflag = false

---@class THlib.ext
---@field replay THlib.ext.Replay
---@field mask_color lstg.Color
---@field mask_alph table
---@field mask_x table
---@field pause_menu_text table
ext = { replay = {} }

ext.mask_color = Color(0, 255, 255, 255)
ext.mask_alph = { 0, 0, 0 }
ext.mask_x = { 0, 0, 0 }
ext.pause_menu_text = { { 'Return to Game', 'Return to Title', 'Give up and Retry' },
                        { 'Return to Game', 'Return to Title', 'Replay Again' } }

function ext.GetPauseMenuOrder()
    return ext.pause_menu_order
end

--Include('THlib/ext/assets.lua')
--Include('THlib/ext/replay.lua')
Include('VNlib/ext/pause_menu.lua')
Include('VNlib/ext/stage_group.lua')

local ext_replay = ext.replay
local e = lstg.eventDispatcher

----------------------------------------------------------------------

e:addListener('onGetInput', function()
    if stage.next_stage then
        lstg.tmpvar = {}
        --SystemLog('clear lstg.tmpvar')

        KeyStatePre = {}
    else
        -- 刷新KeyStatePre
        for k, v in pairs(setting.keys) do
            KeyStatePre[k] = KeyState[k]
        end
        for k, v in pairs(setting.keysys) do
            KeyStatePre[k] = KeyState[k]
        end
    end

    -- 不是录像时更新按键状态
    if true then
        for k, v in pairs(setting.keys) do
            KeyState[k] = GetKeyState(v)
        end
        for k, v in pairs(setting.keysys) do
            KeyState[k] = GetKeyState(v)
        end
    end

end, 0, 'ext.GetInput')

local time_slow_level = { 1, 2, 3, 4 }--60/30/20/15  4个程度


e:addListener('onFrameFunc', function()
    -- 无暂停时执行场景逻辑
    if ext.pause_menu == nil then
        -- 处理录像速度与正常更新逻辑
        DoFrame(true, false)
    else
        --ext.pause.frame()
    end
end, 0, 'ext.FrameFunc')

