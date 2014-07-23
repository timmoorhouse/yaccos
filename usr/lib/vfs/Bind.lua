
local oo    = require("oo")
local vfs   = require("vfs")

local Bind = oo.class("vfs.Bind", vfs.Mount)

function Bind.new(dir, mp, self, klass)
    self = self or {}
    Bind.super.new(dir, mp, self, klass or Bind)
    -- TODO: check dir
    return self
end

function Bind.list(self, path)
	return vfs.list(fs.combine(self._dev, path))
end

function Bind.exists(self, path)
	return vfs.exists(fs.combine(self._dev, path))
end

function Bind.isDir(self, path)
	return vfs.isDir(fs.combine(self._dev, path))
end

function Bind.isReadOnly(self, path)
	return vfs.isReadOnly(fs.combine(self._dev, path))
end

function Bind.getDrive(self, path)
	return vfs.getDrive(fs.combine(self._dev, path))
end

function Bind.getSize(self, path)
	return vfs.getSize(fs.combine(self._dev, path))
end

function Bind.getFreeSpace(self, path)
	return vfs.getFreeSpace(fs.combine(self._dev, path))
end

function Bind.makeDir(self, path)
	vfs.makeDir(fs.combine(self._dev, path))
end

function Bind.move(self, from, to)
	vfs.move(fs.combine(self._dev, from),
	         fs.combine(self._dev, to))
end

function Bind.copy(self, from, to)
	vfs.copy(fs.combine(self._dev, from),
	         fs.combine(self._dev, to))
end

function Bind.delete(self, path)
	vfs.delete(fs.combine(self._dev, path))
end

function Bind.open(self, path, mode)
	return vfs.open(fs.combine(self._dev, path), mode)
end

return Bind
