
local oo     = require("oo")
local ui     = require("ui")
local log    = require("log")
local event  = require("event")

local Screen = oo.class("ui.Screen", ui.Window)

function Screen.new(side, self, klass)
    self = self or {}

    Screen.super.new(side, 1, 1, nil, nil, self, klass or Screen)

    self._side    = side
    self._clicked = nil -- child clicked, use to route drag events

    if side then
        event.listen(event.monitor_touch,  Screen.onMonitorTouchE,  self)
        event.listen(event.monitor_resize, Screen.onMonitorResizeE, self)
    else
        event.listen(event.char,           Screen.onCharE,          self)
        event.listen(event.key,            Screen.onKeyE,           self)
        event.listen(event.mouse_click,    Screen.onMouseClickE,    self)
        event.listen(event.mouse_scroll,   Screen.onMouseScrollE,   self)
        event.listen(event.mouse_drag,     Screen.onMouseDragE,     self)
        event.listen(event.paste,          Screen.onPasteE,         self)
        event.listen(event.term_resize,    Screen.onTermResizeE,    self)
    end

    self:setBackgroundColour(colours.black)
    self:setTextColour(colours.white)

    return self
end

function Screen.onCharE(self, ev, c)
    --log.debug("char "..tostring(c))
    self:_traverse("onChar", c)
    return true
end

function Screen.onKey(self, k)
    log.debug("Screen.onKey "..tostring(k))

    if k == keys.tab then

        -- cycle within top window
        log.debug("TAB")
        if not self._children:empty() then
            local c = self._children:back()
            --print("TAB")
            if not c:focusNext() then
                -- handle wraparound
                c:focusNext()
            end
            return true
        end

    elseif k == keys.grave then

        -- cycle window focus
        log.debug("GRAVE")
        if not self._children:empty() then
            self._children:front():raise()
            return true
        end
    end

end

function Screen.onKeyE(self, ev, k)
    --log.debug("Screen.onKeyE "..tostring(k))
    self:_traverse("onKey", k)
    return true
end

function Screen.onPasteE(self, ev, text)
    -- TODO
    return true
end

function Screen._onClick(self, x, y, button)
    --[[
        TODO:
        set focus (let toplevel do this?)
    ]]
    self._clicked = self:_find("onClick", x, y, button)
end

function Screen.onMouseClickE(self, ev, button, x, y)
    self:_onClick(x, y, button)
    return true
end

function Screen.onMonitorTouchE(self, ev, side, x, y)
    if side == self._side then
        self:_onClick(x, y, 1)
    end
    return true
end

function Screen.onMouseScrollE(self, ev, dir, x, y)
    --[[
        TODO
    ]]
    log.debug("Screen.onMouseScroll")
    return true
end

function Screen.onMouseDragE(self, ev, button, x, y)
    log.debug("Screen.onMouseDrag x="..tostring(x).." y="..tostring(y))
    if self._clicked then
        local cx, cy = self:_offset(self._clicked)
        self._clicked:onDrag(x-cx, y-cy, button)
    end
    return true
end

function Screen._onResizeE(self)
    self:redraw()
end

function Screen.onTermResizeE(self)
    self:_onResize()
    return true
end

function Screen.onMonitorResizeE(self, ev, side)
    if side == self._side then
        self:_onResize()
    end
    return true
end

function Screen.onInvalidate(self, x, y, w, h)
    -- TODO
    self:redraw()
end

return Screen
