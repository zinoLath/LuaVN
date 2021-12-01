local base = "ZinoLib\\"
local path = base.."misc\\"
ZQuads = Include(path..'VertexRenderer.lua')
Vector = Include(path..'BrineVector.lua')
Include(path..'MiscFunctions.lua')
Include(path..'Stack.lua')
path = base.. "BMF\\"
BMF = Include(path..'main.lua')
--path = base.. "player\\"
--Include(path..'player.lua')
path = base.. "zino_menu\\"
MenuSys = Include(path..'main.lua')