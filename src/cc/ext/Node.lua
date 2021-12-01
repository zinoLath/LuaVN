---@type cc.Node
local M = cc.Node

---@return cc.Node
function M:alignCenter()
    return self:alignInner(0.5, 0.5)
end

---@return cc.Node
function M:alignHCenter()
    return self:alignInnerX(0.5)
end

---@return cc.Node
function M:alignVCenter()
    return self:alignInnerY(0.5)
end

---@param ratio_x number
---@param ratio_y number
---@return cc.Node
function M:alignInner(ratio_x, ratio_y)
    local p = self:getParent()
    if not p then
        return self
    end
    local psz = p:getContentSize()
    local sz = self:getContentSize()
    local anc = self:getAnchorPoint()
    local w, h = sz.width * self:getScaleX(), sz.height * self:getScaleY()
    local offset = cc.p(w * anc.x, h * anc.y)
    local posx = (psz.width - w) * ratio_x
    local posy = (psz.height - h) * ratio_y
    local pos = cc.pAdd(cc.p(posx, posy), offset)
    return self:setPosition(pos)
end

---@param ratio_x number
---@return cc.Node
function M:alignInnerX(ratio_x)
    local p = self:getParent()
    if not p then
        return self
    end
    local w = self:getContentSize().width * self:getScaleX()
    local posx = (p:getContentSize().width - w) * ratio_x
    posx = posx + w * self:getAnchorPoint().x
    return self:setPositionX(posx)
end

---@param ratio_y number
---@return cc.Node
function M:alignInnerY(ratio_y)
    local p = self:getParent()
    if not p then
        return self
    end
    local h = self:getContentSize().height * self:getScaleY()
    local posy = (p:getContentSize().height - h) * ratio_y
    posy = posy + h * self:getAnchorPoint().y
    return self:setPositionY(posy)
end

---@return cc.Node
function M:alignLeft(px)
    local p = self:getParent()
    if not p then
        return self
    end
    local sz = self:getContentSize()
    local anc = self:getAnchorPoint()
    return self:setPositionX(px + sz.width * anc.x * self:getScaleX())
end

---@return cc.Node
function M:alignRight(px)
    local p = self:getParent()
    if not p then
        return self
    end
    local psz = p:getContentSize()
    local sz = self:getContentSize()
    local anc = self:getAnchorPoint()
    return self:setPositionX(psz.width - (sz.width * (1 - anc.x)) * self:getScaleX() - px)
end

---@return cc.Node
function M:alignBottom(px)
    local p = self:getParent()
    if not p then
        return self
    end
    local sz = self:getContentSize()
    local anc = self:getAnchorPoint()
    return self:setPositionY(px + sz.height * anc.y * self:getScaleY())
end

---@return cc.Node
function M:alignTop(px)
    local p = self:getParent()
    if not p then
        return self
    end
    local psz = p:getContentSize()
    local sz = self:getContentSize()
    local anc = self:getAnchorPoint()
    return self:setPositionY(psz.height - (sz.height * (1 - anc.y)) * self:getScaleY() - px)
end
