
local net = require("net")

local nfs = {
	protocol = "nfs",
}

autoload(nfs, "net.nfs", "Mount", "Server")

function nfs.showmount(srv, dir, timeout)
	local host = net.dns.resolve(net.nfs.protocol, srv)
	return net.rpc.rpc(net.nfs.protocol, host, { timeout=timeout, }, "showmounts", dir)
end

return nfs
