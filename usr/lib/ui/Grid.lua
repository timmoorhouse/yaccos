
local oo  = require("oo")
local ui  = require("ui")
local log = require("log")

local Grid = oo.class("ui.Grid", ui.Window)

-- TODO

function Grid.new(parent, x, y, w, h, self, klass)
    self = self or {}
    Grid.super.new(parent, x, y, w, h, self, klass or Grid)
    return self
end

function Grid._align(self, ch, axis, info)
    local cs = { ch:getSize() }
    local pad = info.size - cs[axis] -- TODO
    local offset = 0
    if ch._axis[axis].align == ui.alignment.center then
        offset = math.floor(pad / 2)
    elseif ch._axis[axis].align == ui.alignment.back then
        offset = pad
    end
    return info.pos+offset
end

function Grid._layout(self, axis)
    local info = {}

    -- Determine row/column size
    --for k,ch in pairs(self._children) do
    for ch in self._children:iterator() do
        local cax = ch._axis[axis]
        local cp = cax.pos
        local cs = { ch:getSize() }
        if not info[cax.pos] then
            info[cp] = {
                size = 0,
                fill = true,
            }
        end
        info[cp].size = math.max(info[cp].size, cs[axis])
        if not cax.fill then
            info[cp].fill = false
        end
    end

    -- Determine total size
    local sum = 0
    local nfills = 0
    for idx,i in pairs(info) do
        sum = sum + i.size
        if i.fill then
            nfills = nfills + 1
        end
    end

    -- Apply fill padding
    local sz = { self:getSize() }
    --log.debug("Grid._layout pre-fill axis="..tostring(axis).." sz="..tostring(sz[axis]).." info="..textutils.serialize(info))
    if (sum < sz[axis]) and (nfills > 0) then
        local pad = sz[axis] - sum
        local fillidx = 0
        for idx,i in pairs(info) do
            if i.fill then
                i.size = i.size + math.floor(pad/nfills)
                if fillidx < (pad % nfills) then
                    i.size = i.size + 1
                end
                fillidx = fillidx + 1
            end
        end
    end
    --log.debug("Grid._layout post-fill axis="..tostring(axis).." sz="..tostring(sz[axis]).." info="..textutils.serialize(info))

    -- Determine row/column position
    local sum = 1
    for cn,c in pairs(info) do -- TODO: sort by index
        c.pos = sum
        sum = sum + c.size
    end

    return info
end

function Grid._setDirty(self)
    if not self._dirty then
        self._dirty = true
        -- TODO: idle event handler to recalc
        self:_recalc()
    end
end

function Grid._recalc(self)
    local col = self:_layout(1)
    local row = self:_layout(2)

    --for k,ch in pairs(self._children) do
    for ch in self._children:iterator() do
        ch._win.reposition(self:_align(ch, 1, col[ch._axis[1].pos]),
                           self:_align(ch, 2, row[ch._axis[2].pos]))
    end
    self._dirty = nil
end

function Grid.onChildReposition(self, ch)
    self:_setDirty()
end

function Grid.onReposition(self)
    self:_setDirty()
end

return Grid
