
local oo = require("oo")

local ui = {

    alignment = {
        front  = "front",
        center = "center",
        back   = "back",
    },

}

autoload(ui, "ui",
         "Button",
         "Dialog",
         "Grid",
         "Label",
         "MenuButton",
         "Screen",
         "TitleBar",
         "TopLevel",
         "Window")

--[[

TODO:

checkbox
slider/scrollbar
textbox
menubar
menu
listbox
tree?

]]

-- ***************************************************************************

local Position = oo.class("ui.Position")

function Position.new(x, y, self, klass)
    self = self or {}
    Position.super.new(self, klass or Position)
    self.x = x or 1
    self.y = y or 1
    return self
end

ui.Position = Position

-- ***************************************************************************

return ui
