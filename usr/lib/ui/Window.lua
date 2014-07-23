
local oo    = require("oo")
local types = require("types")
local ui    = require("ui")
local log   = require("log")

local Window = oo.class("ui.Window")

function Window.new(parent, x, y, w, h, self, klass)
    --[[
    log.debug("Window.new(parent="..tostring(parent)..
              ",x="..tostring(x)..
              ",y="..tostring(y)..
              ",w="..tostring(w)..
              ",h="..tostring(h)..
              ",klass="..tostring(klass)..
              ")")
    ]]
    self = self or {}
    Window.super.new(self, klass or Window)
    local pwin
    if type(parent) == "string" then
        pwin = peripheral.wrap(parent)
    elseif parent then
        pwin = parent._win
        parent._children:push_back(self)
    end
    pwin = pwin or term.current()
    x = x or 1
    y = y or 1
    if not w or not h then
        w, h = pwin.getSize()
    end
    self._children = types.List.new()
    self._focus = nil -- 0 = we have focus, >0 = index of child with focus
    self._parent = parent
    self._axis = {
        --[[
            pos is a logical position, which may be different from the
            physical position (in the case of a child of a grid, for example,
            the logical position is the grid cell)
        ]]
        {
            pos   = x,
            fill  = true,
            --align = ui.alignment.front,
            align = ui.alignment.center,
        },
        {
            pos   = y,
            fill  = true,
            --align = ui.alignment.front,
            align = ui.alignment.center,
        }
    }
    self._win = window.create(pwin, 1, 1, 1, 1) -- TODO
    self:setBackgroundColour(colours.blue)
    self:setTextColour(colours.white)
    self:reposition(x, y, w, h)
    return self
end

-- **************************************************************************
-- Support routines for subclasses

function Window._recurse(self, f, ...)
    --for k,ch in pairs(self._children) do
    for ch in self._children:iterator() do
        if ch then
            ch[f](ch, ...)
        end
    end
end

function Window._offset(self, w)
    local x = 0
    local y = 0
    while w ~= self do
        if not w then
            error("w not a descendant", 2)
        end
        local wx, wy = w:getPosition()
        x = x + wx - 1
        y = y + wy - 1
        w = w._parent
    end
    return x, y
end

function Window._find(self, f, x, y, ...)
    log.debug("Window._find self="..tostring(self).." x="..tostring(x).." y="..tostring(y))
    if type(f) == "function" and f(self, x, y, ...) then
        return self, x, y
    elseif type(f) == "string" and self[f] and self[f](self, x, y, ...) then
        return self, x, y
    end
    for c in self._children:reverse_iterator() do
        local cx, cy = c:getPosition()
        local cw, ch = c:getSize()
        log.debug("...checking c="..tostring(c).." x="..tostring(cx).." y="..tostring(cy).." w="..tostring(cw).." h="..tostring(ch))
        if (x >= cx) and (y >= cy) and (x < cx+cw) and (y < cy+ch) then
            log.debug("......match")
            return c:_find(f, x-cx+1, y-cy+1, ...)
        end
    end
    return self, x, y
end

function Window._traverse(self, f, ...)
    if type(f) == "function" and f(self, ...) then
        return self
    elseif type(f) == "string" and self[f] and self[f](self, ...) then
        return self
    end
    if self._focus and self._focus > 0 then
        return self._children:element(self._focus):_traverse(f, ...)
    end
    return nil
end

function Window._invalidate(self, x, y, w, h)
    local wx, wy = self:getPosition()
    local ww, wh = self:getSize()
    x = x or wx
    y = y or wy
    w = w or ww
    h = h or wh
    -- TODO
    if self._parent then
        local cx, cy = self:getPosition()
        self._parent:_invalidate(x+cx-1, y+cy-1, w, h)
    end
    self:onInvalidate(x, y, w, h)
end

-- **************************************************************************
-- Stock APIs

function Window.write(self, text)
    self._win.write(text)
end

function Window.clear(self)
    self._win.clear()
end

function Window.clearLine(self)
    self._win.clearLine()
end

function Window.isColour(self)
    return self._win.isColour()
end

function Window.getCursorPos(self)
    return self._win.getCursorPos()
end

function Window.setCursorPos(self, x, y)
    self._win.setCursorPos(x, y)
end

function Window.setCursorBlink(self, enable)
    self._win.setCursorBlink(enable)
end

function Window.setTextColour(self, colour)
    self._foreground = colour
    self._win.setTextColour(colour)
end

function Window.setBackgroundColour(self, colour)
    self._background = colour
    self._win.setBackgroundColour(colour)
end

function Window.scroll(self, n)
    self._win.scroll(n)
end

function Window.setVisible(self, enable)
    self._win.setVisible(enable)
end

function Window.getSize(self)
    return self._win.getSize()
end

function Window.getPosition(self)
    return self._win.getPosition()
end

function Window.redraw(self)
    self._win.setBackgroundColour(self._background)
    self._win.setTextColour(self._foreground)
    self:onRedraw()
    self:_recurse("redraw")
end

function Window.reposition(self, x, y, w, h)
    self._axis[1].pos = x
    self._axis[2].pos = y
    self._win.reposition(x, y, w, h)
    self:onReposition()
    if self._parent then
        self._parent:onChildReposition(self)
    end
end

-- **************************************************************************
-- Stuff intended to be overridden by subclasses

function Window.onRedraw(self)
    self:clear() -- TODO
    --self._win.redraw()
end

function Window.onReposition(self)
end

function Window.onChildReposition(self, ch)
end

function Window._canFocus(self)
    return false
end

function Window.onFocus(self, focus)
end

-- return true if handled
function Window.onClick(self, x, y, button)
    return false
end

function Window.onDrag(self, x, y, button)
end

-- return true if handled
function Window.onChar(self, c)
    return false
end

-- return true if handled
function Window.onKey(self, k)
    return false
end

function Window.onInvalidate(self, x, y, w, h)
end

-- **************************************************************************
-- Extras

--function Window.remove(self, child)
--    self._children:remove(child)
--    child.parent = nil
--end

function Window.xywrite(self, x, y, text)
    self:setCursorPos(x, y)
    self:write(text)
end

function Window.fill(self, c)
    c = c or " "
    local w, h = self:getSize()
    for y = 1,h do
        self:xywrite(1, y, string.rep(c, w))
    end
end

function Window.resize(self, w, h)
    self:reposition(self._axis[1].pos,
                    self._axis[2].pos,
                    w,
                    h)
end

function Window.canFocus(self)
    if self:_canFocus() then
        return true
    end
    --for k,ch in pairs(self._children) do
    for ch in self._children:iterator() do
        if ch:canFocus() then
            return true
        end
    end
    return false
end

function Window.focusNext(self)

    local next

    if not self._focus and self:_canFocus() then

        -- we're next
        next = 0

    else

        -- look for child

        local cid = 1
        if self._focus and self._focus > 0 then
            cid = self._focus
        else
            cid = 1
        end

        --while cid <= #self._children do
        while cid <= self._children:size() do
            if self._children:element(cid):focusNext() then
                next = cid
                break
            end
            cid = cid+1
        end

    end

    if next ~= self._focus then
        local prev = self._focus
        self._focus = next
        if prev == 0 then
            self:onFocus(false)
        elseif next == 0 then
            self:onFocus(true)
        end
    end

    return self._focus ~= nil

end

function Window.raise(self)
    local p = self._parent
    if p then
        local idx = p._children:find(self)
        p._children:remove(self)
        p._children:push_back(self)
        if p._focus then
            if p._focus == idx then
                p._focus = p._children:size()
            elseif p._focus > idx then
                p._focus = p._focus - 1
            end
        end
        self:_invalidate()
    end
end

return Window
