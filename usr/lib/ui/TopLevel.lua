
local oo = require("oo")
local ui = require("ui")

--[[
	Eventually, this should be a full-fledged window with:
	- titlebar
	- menu button
	- minimize/maximize/close buttons
	- move/resize handling
	- etc
]]

local TopLevel = oo.class("ui.TopLevel", ui.Grid)

function TopLevel.new(parent, x, y, w, h, self, klass)
    self = self or {}
    TopLevel.super.new(parent, x, y, w, h, self, klass or TopLevel)
    local tb = ui.TitleBar.new(self, 1, 1, w, 1)
    tb._axis[2].fill = false
    return self
end

return TopLevel
