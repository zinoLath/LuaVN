---BMF LuaSTG System by Zino Lath v0.01a
local M = {}
local _bop = ccb.BlendOperation
local _bfac = ccb.BlendFactor
local GCSD = "ZinoLib\\BMF\\"
M.states = {}
M.fonts = {}
LoadFX("zino_font", GCSD.."zino_font.glsl",GCSD.."zino_fontv.glsl")
M.font_functions = {}
function M:createState(name, _color, _gradient, _border, _alpha)
    _color = _color or Color(255,255,255,255)
    _gradient = _gradient or Color(255,128,128,128)
    _border = _border or Color(255,0,0,0)
    _alpha = _alpha or 1
    name = string.format("BMFSTATE:%s", name)
    local base = CreateRenderMode(name,_bop.ADD, _bfac.SRC_ALPHA, _bfac.ONE_MINUS_SRC_ALPHA,"zino_font")
    base:setColor("u_gradient", _color)
    base:setColor("u_color", _gradient)
    base:setColor("u_border", _border)
    base:setFloat("u_alpha", _alpha)
    self.states[name] = base
    return base
end
local base_state = M:createState("base")
function M:loadFont(name,path,imgpath)
    local FU = cc.FileUtils:getInstance()
    local xml = require('util.xmlSimple').newParser()
    local data = xml:ParseXmlText(FU:getStringFromFile(path))
    local tex = LoadTexture("bmftexture:" .. name, imgpath)
    local ret = {}
    local chars = {}
    local function getValueN(tb, id)
        return tonumber(tb[id])
    end
    for k,v in pairs(data.font.chars.char) do
        chars[string.char(getValueN(v, '@id'))] = {
            id = (getValueN(v, '@id')),
            x = getValueN(v, '@x'), y = getValueN(v, '@y'),
            width = getValueN(v, '@width'), height = getValueN(v, '@height'),
            xoffset = getValueN(v, '@xoffset'), yoffset = getValueN(v, '@yoffset'),
            xadvance = getValueN(v, '@xadvance'),
            sprite = LoadImage(name .. v['@id'], "bmftexture:" .. name, getValueN(v, '@x'),getValueN(v, '@y'),
                    getValueN(v, '@width'), getValueN(v, '@height'),0,0,false),
            sprite_name = 'philosopher_' .. v['@id']
        }
        local w = Color(255,255,255,255)
        local b = Color(255,0,0,0)
        local spr = chars[string.char(getValueN(v, '@id'))].sprite
        local color_tb = {w,w,b,b,w,w}
        for k,v in ipairs(color_tb) do
            spr:setColor(v,k-1)
        end
        spr:setRenderMode(base_state)
        --SetImageCenter(name .. v['@id'],0,getValueN(v, '@height'))
        SetImageCenter(name .. v['@id'],0,getValueN(v, '@height')/2)
    end
    ret.name = data.font.info['@face']
    ret.size = tonumber(data.font.info['@size'])
    ret.bold = data.font.info['@bold'] == '1'
    ret.charset = data.font.info['@charset']
    ret.stretchH = data.font.info['@stretchH']
    ret.smooth = data.font.info['@smooth']
    ret.padding = data.font.info['@padding']
    ret.spacing = data.font.info['@spacing']
    ret.outline = tonumber(data.font.info['@outline'])
    ret.lineHeight = tonumber(data.font.common['@lineHeight'])
    ret.base = tonumber(data.font.common['@base'])
    ret.scaleW = tonumber(data.font.common['@scaleW'])
    ret.scaleH = tonumber(data.font.common['@scaleH'])
    ret.pages = tonumber(data.font.common['@pages'])
    ret.alpha = data.font.info['@alphaChnl'] == '1'
    ret.chars = chars
    self.fonts[name] = ret
    for k,v in pairs(self.font_functions) do
        ret[k] = v
    end
    return ret
end
function M.font_functions:setMonospace(monospace, mono_exception)
    if monospace then
        self.monospace = monospace
        self.mono_exception = mono_exception
    else
        self.monospace = nil
        self.mono_exception = nil
    end
    return self
end
function M.font_functions:getSize(str,scale)
    local cursor = Vector(0,self.base)
    local chars = self.chars
    local cwidth = 0
    local cxoff = 0
    local cxadvance = 0
    local maxheight = 0
    local maxbottom = 0
    local linecount = 1
    local base_c = cursor:clone()
    local monospace = self.monospace
    for i=1, #str do
        local c = str:sub(i,i)
        if c ~= "\n" then
            local char = chars[c]
            if monospace then
                local current_space = monospace
                if self.mono_exception then
                    current_space = self.mono_exception[c] or current_space
                end
                cursor.x = cursor.x + current_space
                cxadvance = current_space
                cwidth = current_space
            else
                cwidth = char.width
                cursor.x = cursor.x + char.xadvance
                cxadvance = char.xadvance
            end
            cxoff = char.xoffset
            maxheight = math.max(maxheight,char.height/2 - char.yoffset)
            maxbottom = math.min(maxbottom,char.height/-2 + char.yoffset)
        else
            base_c.y = base_c.y - self.lineHeight*scale
            linecount = linecount + 1
            cursor = base_c
            cursor.x = 0
        end
    end
    return (cursor.x - cxadvance + cwidth)*scale, (linecount * self.lineHeight)*scale
end
function M.font_functions:render(str,x,y,scale,halign,valign,rm,offsetfunc)
    halign = halign or "center"
    valign = valign or "vcenter"
    local wd, hg = self:getSize(str,scale)
    local cursor = Vector(x,y - self.base*scale/2)
    local vec = Vector(0,0)
    if halign == "center" then
        cursor.x = cursor.x - wd/2
    elseif halign == 'right' then
        cursor.x = cursor.x - wd
    end
    if valign == "bottom" then
        cursor.y = cursor.y + hg
    elseif valign == 'vcenter' then
        cursor.y = cursor.y + hg/2
    elseif valign == 'top' then
        cursor.y = cursor.y
    end
    local base_c = cursor:clone()
    local chars = self.chars
    local monospace = self.monospace
    local _rm
    if rm then
        _rm = self.fonts[string.format("BMFSTATE:%s", rm)]
    end
    for i=1, #str do
        local c = str:sub(i,i)
        if c ~= "\n" then
            local char = chars[c]
            local offset = char.xoffset*scale
            if offsetfunc then
                vec = offsetfunc(i,c,str)
            end
            if rm then
                char.sprite:setRenderMode(_rm)
            end
            Render(char.sprite,cursor.x + offset + vec.x,cursor.y - char.yoffset*scale + vec.y,
                    0,scale,scale,0)
            if monospace then
                local current_space = monospace
                if self.mono_exception then
                    current_space = self.mono_exception[c] or current_space
                end
                cursor.x = cursor.x + current_space*scale
            else
                cursor.x = cursor.x + char.xadvance*scale
            end
        else
            base_c.y = base_c.y - self.lineHeight*scale
            cursor = base_c
        end
    end
end
function M.font_functions:clone()
    local ret = {}
    for k,v in pairs(self) do
        local var = v
        if type(v) == "table" then
            var = {}
            for _k,_v in pairs(v) do
                var[_k] = _v
            end
        end
        ret[k] = var
    end
    return ret
end
return M