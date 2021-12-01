--

local world = {
    l      = -192, r = 192, b = -224, t = 224,
    boundl = -224, boundr = 224, boundb = -256, boundt = 256,
    --scrl = 32, scrr = 416, scrb = 16, scrt = 464,
    scrl   = 128, scrr = 512, scrb = 16, scrt = 464,
    pl     = -192, pr = 192, pb = -224, pt = 224
}
--- l/r/b/t: world的逻辑坐标范围
--- bound(l/r/b/t): 边界范围，超出范围的游戏对象会自动回收
--- scr(l/r/b/t): l/r/b/t在screen坐标系下的坐标
--- p(l/r/b/t): 用于player限位
lstg.world = world

--- screen的大小总是640x480，与world匹配
--- scale dx dy则根据实际游戏的分辨率（由setting决定）计算
screen = {}
function lstg.calcScreen()
    local resx = setting.resx
    local resy = setting.resy
    ---屏幕宽度
    screen.width = 1280
    ---屏幕高度
    screen.height = 720
    if setting.resx > setting.resy then
        --适应高度
        local scale = resy / screen.height
        screen.scale = scale
        local dx = (resx - scale * screen.width) / scale / 2
        screen.dx = dx
        screen.dy = 0
    else
        --适应宽度
        local scale = resx / screen.width
        screen.scale = scale
        local dy = (resy - scale * screen.height) / scale / 2
        screen.dy = dy
        screen.dx = 0
    end
end
lstg.calcScreen()

function _SetBound()
    local w = lstg.world
    SetBound(w.boundl, w.boundr, w.boundb, w.boundt)
end
_SetBound()

--- 坐标系变换
--- 计算结果结果并非实际屏幕坐标系，而是screen的坐标系
--- 用于boss扭曲效果时请将结果加上screen.dx和screen.dy
function WorldToScreen(x, y)
    local w = lstg.world
    local sc_x = (w.r - w.l) / (w.scrr - w.scrl)
    local sc_y = (w.t - w.b) / (w.scrt - w.scrb)
    local ret_x = (w.scrl + sc_x * (x - w.l))
    local ret_y = (w.scrb + sc_y * (y - w.b))
    return ret_x, ret_y
end

function WorldToGame(x, y, flipY)
    x, y = WorldToScreen(x, y)
    if flipY then
        y = screen.height - y
    end
    local sc = screen.scale
    return (x + screen.dx) * sc, (y + screen.dy) * sc
end

function _3DToWorld(x, y, z)
    local view3d = lstg.view3d
    local world = lstg.world
    local m1 = math.Mat4:createPerspective(
            view3d.fovy,
            -(world.r - world.l) / (world.t - world.b),
            view3d.z[1], view3d.z[2])
    local eye = math.Vec3(view3d.eye[1], view3d.eye[2], view3d.eye[3])
    local target = math.Vec3(view3d.at[1], view3d.at[2], view3d.at[3])
    local up = math.Vec3(view3d.up[1], view3d.up[2], view3d.up[3])
    local m2 = math.Mat4:createLookAt(eye, target, up)
    local m = m1 * m2
    local v = m:transformVector(x, y, z, 1)
    local xx, yy, zz, ww = v.x, v.y, v.z, v.w
    xx = xx / ww
    yy = yy / ww
    xx = (xx + 1) * 0.5 * (world.scrr - world.scrl)
    yy = (yy + 1) * 0.5 * (world.scrt - world.scrb)
    return xx + world.l, yy + world.b
end
