
local oo   = require("oo")
local net  = require("net")
local task = require("task")
local log  = require("log")

local Server = oo.class("net.nfs.Server", task.Daemon)

function Server.new(self, klass)
    self = self or {}
    Server.super.new(self, klass or Server)
    return self
end

function Server.status(self)
    return net.rpc.handlers(net.nfs.protocol) > 0
end

function Server.start(self)
    local filectr = 0
    local files = {}
    local mountctr = 0
    local mounts = {}
    net.rpc.register(net.nfs.protocol, "mount",
                    function(dir)
                        mountctr = mountctr + 1
                        local mh = mountctr
                        mounts[mh] = { dir=dir, host=net.rpc.rpcinfo(), }
                        return mh
                    end)
    net.rpc.register(net.nfs.protocol, "umount",
                    function(mh)
                        mounts[mh] = nil
                    end)
    net.rpc.register(net.nfs.protocol, "showmounts",
                    function(dir)
                        local m = {}
                        for k,v in pairs(mounts) do
                            if not dir or dir == v.dir then
                                table.insert(m, { dir="/"..v.dir, host=v.host, })
                            end
                        end
                        return m
                    end)
    local function path(mh, rpath)
        return fs.combine(mounts[mh].dir, rpath)
    end
    net.rpc.register(net.nfs.protocol, "list",
                    function(mh, rpath)
                        return fs.list(path(mh, rpath))
                    end)
    net.rpc.register(net.nfs.protocol, "exists",
                    function(mh, rpath)
                        return fs.exists(path(mh, rpath))
                    end)
    net.rpc.register(net.nfs.protocol, "isDir",
                    function(mh, rpath)
                        --log.debug("isDir("..rpath..")="..tostring(fs.isDir(path(mh,rpath))))
                        return fs.isDir(path(mh, rpath))
                    end)
    net.rpc.register(net.nfs.protocol, "isReadOnly",
                    function(mh, rpath)
                        return fs.isReadOnly(path(mh, rpath))
                    end)
    net.rpc.register(net.nfs.protocol, "getDrive",
                    function(mh, rpath)
                        return fs.getDrive(path(mh, rpath))
                    end)
    net.rpc.register(net.nfs.protocol, "getSize",
                    function(mh, rpath)
                        return fs.getSize(path(mh, rpath))
                    end)
    net.rpc.register(net.nfs.protocol, "getFreeSpace",
                    function(mh, rpath)
                        return fs.getFreeSpace(path(mh, rpath))
                    end)
    net.rpc.register(net.nfs.protocol, "makeDir",
                    function(mh, rpath)
                        return fs.makeDir(path(mh, rpath))
                    end)
    net.rpc.register(net.nfs.protocol, "move",
                    function(mh, from, to)
                        return fs.move(path(mh, from), path(mh, to))
                    end)
    net.rpc.register(net.nfs.protocol, "copy",
                    function(mh, from, to)
                        return fs.copy(path(mh, from), path(mh, to))
                    end)
    net.rpc.register(net.nfs.protocol, "delete",
                    function(mh, rpath)
                        return fs.delete(path(mh, rpath))
                    end)
    net.rpc.register(net.nfs.protocol, "open",
                    function(mh, rpath, mode)
                        filectr = filectr + 1
                        local f = fs.open(path(mh, rpath), mode)
                        local fh = filectr
                        files[fh] = f
                        return fh
                    end)
    net.rpc.register(net.nfs.protocol, "_fop",
                    function(fh, op, ...)
                        --print("fop:"..op)
                        local f = files[fh]
                        if f then
                            if op == "close" then
                                files[fh] = nil
                            end
                            return f[op](...)
                        end
                    end)
    net.dns.host(net.nfs.protocol, net.hostname())
end

function Server.stop(self)
    net.dns.unhost(net.nfs.protocol)
    net.rpc.unregister(net.nfs.protocol)
end

return Server
