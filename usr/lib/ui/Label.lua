
local oo = require("oo")
local ui = require("ui")

local Label = oo.class("ui.Label", ui.Window)

function Label.new(parent, text, x, y, w, h, self, klass)
    self = self or {}
    Label.super.new(parent, x, y, w or #text, h or 1, self, klass or Label)
    self:text(text)
    return self
end

function Label.onRedraw(self)
    self:xywrite(1, 1, self._text or "")
end

Label.onReposition = Label.onRedraw

function Label.text(self, t)
    if t then
        self._text = t
        self:resize(string.len(t),1)
    end
    return self._text
end

return Label
