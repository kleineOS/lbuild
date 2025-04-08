-- SPDX-License-Identifier: MIT

local c = require("build.common")
local config = require("config")

local uboot_step = require("build.steps.uboot")

local commargs = config.commargs
local uboot_args = config.uboot_args
local simple_args = config.simple_args

---@param extraargs string[]
---@return string
local function qemu_cmd(extraargs)
	local baseargs = commargs
	c.concatt(baseargs, extraargs)

	local cmd = "qemu-system-riscv64"

	for _, arg in ipairs(baseargs) do
		cmd = cmd .. " " .. arg
	end

	return cmd
end

---@vararg string
local function checks(...)
	local _, kernel = ...

	if kernel == nil then
		print("error: expected kernel passed as an argument")
		os.exit(1)
	end

	if not c.exists(kernel) then
		print("error: " .. kernel .. " is not a valid file")
		os.exit(1)
	end
end

-- TODO: use the kernel
---@vararg string
local function full(...)
	local _, kernel = ...
	checks(...)

	local deps = uboot_step()
	local args = uboot_args(deps[1], deps[2])
	c.execute(qemu_cmd(args))
end

---@vararg string
local function simple(...)
	local _, kernel = ...
	checks(...)

	local args = simple_args(kernel)
	c.execute(qemu_cmd(args))
end

return {
	full = full,
	simple = simple,
}
