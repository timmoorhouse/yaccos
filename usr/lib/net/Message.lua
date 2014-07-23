
local oo = require("oo")

local Message = oo.class("net.Message")

function Message.new(protocol, msg, dest, self, klass)
    self = self or {}
    Message.super.new(self, klass or Message)

    -- Following conventions of stock rednet API:
    self.nMessageID = math.random(1, 2147483647)
    self.nRecipient = dest
    self.message    = msg
    self.sProtocol  = protocol

   	-- Extensions:
	--sid  = os.getComputerID(),
	--sl   = os.getComputerLabel(),
	--day  = os.day(),
	--time = os.time(),

	--self:_setuuid()
    return self
end

function Message.unserialize(raw)
	if type(raw) == "table" and raw.nMessageID then
		self = raw
	else
		self = { message=raw, }
	end
	Message.super.new(self, Message)
	return self
end

-- TODO: obsolete
function Message._setuuid(self)
	if self._m.sid then
		-- TODO: simplify uuid
		self._m.uuid = tostring(self._m.sid)..":"..tostring(self._m.day)..":"..tostring(self._m.time)..":"..tostring(seqno())
	end
end

function Message.serialize(self)
	return self
end

-- TODO
function Message.sender(self)
	return "???"
end

function Message.uuid(self)
	return self.nMessageID
end

function Message.dest(self)
	return self.nRecipient
end

function Message.msg(self)
	return self.message
end

return Message
