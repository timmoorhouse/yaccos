
local oo = require("oo")
local ui = require("ui")

local Button = oo.class("ui.Button", ui.Window)

function Button.new(parent, text, x, y, w, h, self, klass)
    self = self or {}
    Button.super.new(parent, x, y, w or (#text+2), h or 1, self, klass or Button)
    self:text(text or "")
    return self
end

function Button.__tostring(self)
    return "Button "..(self._text or "")
end

function Button.onRedraw(self)
    if self._focus == 0 then
        self:xywrite(1, 1, ">"..(self._text or "").."<")
    else
        self:xywrite(1, 1, "["..(self._text or "").."]")
    end
end

Button.onReposition = Button.onRedraw

function Button.text(self, t)
    if t then
        self._text = t
        self:resize(string.len(t)+2,1) -- TODO
    end
    return self._text
end

function Button._canFocus(self)
    return true
end

function Button.onFocus(self, focus)
    if focus then
        self:setTextColour(colours.yellow)
        self:setBackgroundColour(colours.cyan)
    else
        self:setTextColour(colours.white)
        self:setBackgroundColour(colours.blue)
    end
    self:_invalidate()
end

return Button
