---from LuaSTG_er+ 1.02
---data/Thlib/misc/misc.lua
---comment by Xrysnow 2017.09.09


LoadTexture('misc', 'VNlib\\misc\\misc.png')
LoadImage('player_aura', 'misc', 128, 0, 64, 64)
LoadImageGroup('bubble', 'misc', 192, 0, 64, 64, 1, 4)
LoadImage('boss_aura', 'misc', 0, 128, 128, 128)
SetImageState('boss_aura', 'mul+add', Color(0x80FFFFFF))
LoadImage('border', 'misc', 128, 192, 64, 64)
LoadImage('leaf', 'misc', 0, 32, 32, 32)
LoadImage('white', 'misc', 56, 8, 16, 16)
LoadTexture('particles', 'VNlib\\misc\\particles.png')
LoadImageGroup('parimg', 'particles', 0, 0, 32, 32, 4, 4)
LoadImageFromFile('img_void', 'VNlib\\misc\\img_void.png')

local int = int
local sin = sin
local cos = cos
local GROUP_GHOST = GROUP_GHOST
local object_render = object.render
local SetImageState = SetImageState
local Color = Color
local Render = Render
local Del = Del
local Render4V = Render4V

---@class THlib.misc
misc = {}

---
---停止粒子发射，存活数为0后删除自己
function misc.KeepParticle(o)
    o.class = ParticleKepper
    PreserveObject(o)
    ParticleStop(o)
    o.bound = false
    o.group = GROUP_GHOST
end

local task_Do = task.Do
local task_New = task.New
local coroutine_status = coroutine.status

---任务类
---具有group属性，协程结束时执行Del
---@class THlib.tasker:object
tasker = Class(object)

function tasker:init(f, group)
    self.group = group or GROUP_GHOST
    task_New(self, f)
end
function tasker:frame()
    task_Do(self)
    if coroutine_status(self.task[1]) == 'dead' then
        Del(self)
    end
end

---@class THlib.ParticleKepper:object
ParticleKepper = Class(object)

function ParticleKepper:frame()
    if ParticleGetn(self) == 0 then
        Del(self)
    end
end

---全屏遮罩过渡效果
---@class THlib.mask_fader:object
mask_fader = Class(object)

function mask_fader:init(mode)
    self.layer = LAYER_TOP + 100
    self.group = GROUP_GHOST
    self.open = (mode == 'open')
end

function mask_fader:frame()
    if self.timer == 30 then
        Del(self)
    end
end

function mask_fader:render()
    SetViewMode 'ui'
    if self.open then
        SetImageState('white', '', Color(255 - self.timer * 8.5, 0, 0, 0))
    else
        SetImageState('white', '', Color(self.timer * 8.5, 0, 0, 0))
    end
    if setting.resx > setting.resy then
        RenderRect('white', 0, 640, 0, 480)
    else
        RenderRect('white', 0, 396, 0, 528)
    end
end

CopyImage('.white.star', 'white')
SetImageState('.white.star', 'mul+sub',
              Color(255, 255, 255, 255))

CopyImage('.white.rev', 'white')
SetImageState('.white.rev', 'add+sub',
              Color(255, 255, 255, 255))