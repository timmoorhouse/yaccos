
local types = require("types")
local net   = require("net")

local vfs = {}

local native = {
	list         = fs.list,
	exists       = fs.exists,
	isDir        = fs.isDir,
	isReadOnly   = fs.isReadOnly,
	getDrive     = fs.getDrive,
	getSize      = fs.getSize,
	getFreeSpace = fs.getFreeSpace,
	makeDir      = fs.makeDir,
	move         = fs.move,
	copy         = fs.copy,
	delete       = fs.delete,
	open         = fs.open,
	-- skip getName
	-- skip combine
	-- skip getDir
}

autoload(vfs, "vfs",
         "Bind",
         "Mount",
         "nfs")

-- **************************************************************************

local _mounts = types.List.new()
--local _local = Bind.new("", "")

function vfs.mounts()
	return _mounts:iterator()
end

function vfs.mount(m)
	if not vfs.exists(m:mountPoint()) or not vfs.isDir(m:mountPoint()) then
		error("Mount point does not exist or is not a directory")
	end
	_mounts:push_front(m)
end

function vfs.umount(path)
	local dev, rpath = vfs.resolve(path)
	if rpath ~= "" then
		return -- path is not a mount point
	end
	-- Check everything up to the mount to handle case of mounts within mounts
	local idx = 1
	while true do
		local m = _mounts:element(idx)
		local mp = m:mountPoint()
		if m == dev then
			_mounts:remove(m)
			break
		elseif string.sub(mp, 1, string.len(path)+1) == path.."/" then
			_mounts:remove(m)
		else
			idx = idx + 1
		end
	end
end

-- TODO: make local
function vfs.resolve(path)
	for m in vfs.mounts() do
		local mp = m:mountPoint()
		if path == mp then
			return m, ""
		elseif string.sub(path, 1, string.len(mp)+1) == mp.."/" then
			return m, string.sub(path, string.len(mp)+2)
		end
	end
	return nil, path
end

local function devcall(dev, f, ...)
	if not dev then
		return native[f](...)
	end
	local r = { pcall(dev[f], dev, ...) }
	if r[1] then
		return unpack(r, 2)
	else
		local mp = dev:mountPoint()
		local msg = f.." on "..mp.." failed, unmounting "..tostring(r[2])
		print(msg)
		net.syslog.log(msg)
		vfs.umount(mp)
		error(msg, 3)
	end
end

-- fs API

for i,v in ipairs({ "list",
                    "exists",
                    "isDir",
                    "isReadOnly",
                    "getDrive",
                    "getSize",
                    "getFreeSpace",
                    "makeDir",
                    "delete",
                    "open",
                  }) do
    vfs[v] =
        function(path, ...)
        	local dev, rpath = vfs.resolve(path)
            return devcall(dev, v, rpath, ...)
        end
end

vfs.getName = fs.getName
vfs.getDir  = fs.getDir
vfs.find    = fs.find -- TODO

function vfs.move(from, to)
	local devf, rpathf = vfs.resolve(from)
	local devt, rpatht = vfs.resolve(to)
	if devcall(devt, "exists", rpatht) then
		error("Destination file exists", 2)
	elseif devf == devt then
		devcall(devf, "move", rpathf, rpatht)
	else
		copy(from, to)
		devcall(devf, "delete", rpathf)
	end
end

function vfs.copy(from, to)
	local devf, rpathf = vfs.resolve(from)
	local devt, rpatht = vfs.resolve(to)
	if devcall(devt, "exists", rpatht) then
		error("Destination file exists", 2)
	elseif devf == devt then
		devcall(devf, "copy", rpathf, rpatht)
	else
		local ff = devcall(devf, "open", rpathf, "r")
		local ft = devcall(devt, "open", rpatht, "w")
		local lines = ff.readAll()
		ft.write(lines)
		ff.close()
		ft.close()
	end
end

vfs.combine = fs.combine

return vfs
