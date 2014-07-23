
local nfs = {
	protocol = "nfs",
}

autoload(nfs, "net.nfs", "Mount", "Server")

return nfs
