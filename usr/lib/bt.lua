
--[[
	Behaviour Trees

	Roughly follows the structure of the Behaviour Tree Start Kit
	(https://github.com/aigamedev/btsk).
]]

local bt = {

	Status = {
		invalid = "invalid",
		success = "success",
		failure = "failure",
		running = "running",
		aborted = "aborted",
	},

}

autoload(bt, "bt",
         "Agent",
         "All",
         "Any",
         "Attack",
         "Behaviour",
         "Composite",
         "Condition",
         "Dig",
         "Go",
         "Pad",
         "Refuel",
         "Retry",
         "SavePosition",
         "Selector",
         "Sequence",
         "Sleep",
         "Unload")

return bt
