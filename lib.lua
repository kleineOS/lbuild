-- SPDX-License-Identifier: MIT

--! simple runner for building and running the kernel
--! inspired partially by how zig's build scripts work

---@class Command
---@field name string the name that invokes the command
---@field desc string? the description of the command
---@field runner function the function to execute the command

---@param name string
---@param runner function
---@param desc string?
---@return Command
local cmd = function(name, runner, desc)
	return { name = name, runner = runner, desc = desc }
end

---@param commands Command[]
---@vararg string
local function evaluate(commands, ...)
	local function error()
		print("available commands:")
		for _, currcmd in ipairs(commands) do
			local desc = currcmd.desc
			if desc == nil then
				desc = "no description provided"
			end
			print("\t" .. currcmd.name .. "\t- " .. desc)
		end
		os.exit(1)
	end

	local command = ...
	if command == nil then
		print("error: no argument given\n")
		error()
	end

	local runner = function(...)
		local arg0 = ...
		print("error: unrecognised argument " .. arg0 .. "\n")
		error()
	end

	for _, currcmd in ipairs(commands) do
		if currcmd.name == command then
			runner = currcmd.runner
		end
	end

	runner(...)
end

return {
	cmd = cmd,
	evaluate = evaluate,
}
