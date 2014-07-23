
local event = require("event")
local log   = require("log")
local types = require("types")
local net   = require("net")

local rpc = {
	protocol = "rpc",
}

local _handlers = {}

function rpc.handlers(protocol)
	if _handlers[protocol] then
		return 1 -- TODO
	else
		return 0
	end
end

function rpc.register(protocol, name, f)
	if not protocol then
		error("protocol missing", 2)
	end
	if not _handlers[protocol] then
		_handlers[protocol] = {}
	end
	_handlers[protocol][name] = f
end

function rpc.unregister(protocol, name)
	if not protocol then
		error("protocol missing", 2)
	end
	if _handlers[protocol] then
		if name then
			_handlers[protocol][name] = nil
		else
			_handlers[protocol] = nil
		end
	end
end

local _rpcinfo = types.List.new()

local function onMessage(protocol, src, msg)
	local m = msg:msg()

	if m.result then

		--log.debug("rpc result src="..tostring(src).." msg="..textutils.serialize(m))
		os.queueEvent(event.rpc, m.id, unpack(m.result))

	elseif m.f then

		local f
		local obj
		if m.oid then
			obj = oo.object(m.oid)
			f = obj[m.f]
		elseif _handlers[m.domain] then
		   	f = _handlers[m.domain][m.f]
		end
		if f then
			_rpcinfo:push_back({ src=src, })
			local r
			if obj then
				r = { f(obj, unpack(m.args)) }
			else
				r = { f(unpack(m.args)) }
			end
			_rpcinfo:pop_back()
			--log.debug("rpc call done src="..tostring(src).." id="..tostring(m.id))
			net.send(src, { id=m.id, result=r }, protocol)
		else
			net.syslog.log("No handler for rpc call "..m.f)
		end

	else

		error("Internal error")

	end

	return true
end

net.listen(rpc.protocol, onMessage)

function rpc.rpc(domain, dest, opts, f, ...)
	if not domain then
		error("protocol missing", 2)
	end
	local id = math.random(1, 2147483647) -- TODO
	--log.debug("rpc opts="..textutils.serialize(opts).." id="..tostring(id).." dest="..tostring(dest).." f="..f)
	net.send(dest, { id=id, oid=opts.oid, f=f, domain=domain, args={...}, }, rpc.protocol)
    local timeout_id
    if opts.timeout then
    	timeout_id = os.startTimer(opts.timeout)
    end
    while true do
   		local ev = { event.pull(event.rpc, timeout_id) }
    	if ev[1] == event.rpc then
    		--log.debug("rpc event "..textutils.serialize(ev))
    		if ev[2] == id then
    			return unpack(ev, 3)
    		end
    		error("out of sequence rpc result")
    	else
    		log.debug("rpc timeout dest="..tostring(dest).." f="..f)
    		net.syslog.log("RPC call to "..tostring(dest)..":"..f.." timed out")
    		error("RPC timeout domain="..domain.. " dest="..tostring(dest).. " f="..f, 2)
    	end
	end
end

function rpc.rpcinfo()
	local info = _rpcinfo:back()
	return info.src
end

function rpc.proxy(domain, dest, opts)
	if not domain then
		error("protocol missing", 2)
	end
    local self = {
    	_domain  = domain,
    	_dest    = dest,
    	_opts    = opts,
    }
    setmetatable(self, {
    	__index = function(self, k)
   				return function(...)
					return rpc.rpc(self._domain, self._dest, self._opts, k, ...)
   				end
    	    end,
	})
    return self
end

return rpc
