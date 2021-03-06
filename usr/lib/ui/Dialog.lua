
local oo = require("oo")
local ui = require("ui")
local log = require("log")


-- TODO

local Dialog = oo.class("ui.Dialog", ui.TopLevel)

function Dialog.new(parent, x, y, w, h, self, klass)
    self = self or {}
    Dialog.super.new(parent, x, y, w, h, self, klass or Dialog)
    self._grid = ui.Grid.new(self, 1, 2, w, h)
    ui.Label.new(self._grid, "some message", 1, 1)
    local ok = ui.Button.new(self._grid, "OK", 1, 2)
    --ok._y.fill = false
    local a = ui.Button.new(self._grid, "A", 2, 1)
    local b = ui.Button.new(self._grid, "B", 2, 2)
    a.clicked:listen(function() log.debug("A CLICKED") end)
    b.clicked:listen(function() log.debug("B CLICKED") end)
    self._grid:resize(w, h)
    return self
end

function Dialog.onReposition(self)
    local x, y = self:getPosition()
    local w, h = self:getSize()
    if self._grid then
        -- TODO
        self._grid:reposition(x, y+1, w, h-1)
    end
end

return Dialog
