
local oo  = require("oo")
local vfs = require("vfs")
local net = require("net")

local Mount = oo.class("net.nfs.Mount", vfs.Mount)

function Mount.new(dev, mp, self, klass)
    self = self or {}
    Mount.super.new(dev, mp, self, klass or Mount)
    local i,e = string.find(dev.."", ":", 1, true) -- TODO: get rid of hack with appending ""!!!!!!!!!
    if not i then
    	error("Invalid device")
    end
    self._hostname = string.sub(dev, 1, i-1)
    self._dir      = string.sub(dev, i+1)
    self._host = net.dns.resolve(net.nfs.protocol, self._hostname)
    if not self._host then
    	error("Host "..self._hostname.." not found")
    end
	self._timeout = 5 -- TODO
	self._h       = self:rpc("mount", self._dir) -- might generate error
    return self
end

function Mount.rpc(self, f, ...)
	return net.rpc.rpc(net.nfs.protocol, self._host, { timeout=self._timeout, }, f, ...)
end

for i,v in ipairs({ "list",
                    "exists",
                    "isDir",
                    "isReadOnly",
                    "getDrive",
                    "getSize",
                    "getFreeSpace",
                    "makeDir",
                    "move",
                    "copy",
                    "delete",
                  }) do
    Mount[v] =
        function(self, ...)
            return self:rpc(v, self._h, ...)
        end
end

function Mount.open(self, path, mode)
	local fh = self:rpc("open", self._h, path, mode)
	local r = {}
	for i,v in ipairs({ "close",
						"flush",
						"readAll",
						"readLine",
						"write",
					 }) do
		r[v] = function(...)
				return self:rpc("_fop", fh, v, ...)
			end
	end
	return r
end

return Mount
