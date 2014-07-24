
local oo    = require("oo")
local vfs   = require("vfs")

local Bind = oo.class("vfs.Bind", vfs.Mount)

function Bind.new(dir, mp, self, klass)
    self = self or {}
    Bind.super.new(dir, mp, self, klass or Bind)
    -- TODO: check dir
    return self
end

for i,v in ipairs({ "list",
                    "exists",
                    "isDir",
                    "isReadOnly",
                    "getDrive",
                    "getSize",
                    "getFreeSpace",
                    "makeDir",
                    "delete",
                  }) do
    Bind[v] =
        function(self, path)
            return vfs[v](fs.combine(self._dev, path))
        end
end

function Bind.move(self, from, to)
	vfs.move(fs.combine(self._dev, from),
	         fs.combine(self._dev, to))
end

function Bind.copy(self, from, to)
	vfs.copy(fs.combine(self._dev, from),
	         fs.combine(self._dev, to))
end

function Bind.open(self, path, mode)
	return vfs.open(fs.combine(self._dev, path), mode)
end

return Bind
