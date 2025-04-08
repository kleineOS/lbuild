-- SPDX-License-Identifier: MIT

-- OLD STUFF, LEFT IN FOR REFERENCE

local c = require("build.common")

---@return string
local function buildsbi()
	local sbi_dir = c.projroot .. "target/opensbi/"
	local firmware_bin = sbi_dir .. "build/platform/generic/firmware/fw_dynamic.bin"

	if c.exists(firmware_bin) then
		print("info: OpenSBI exists in " .. sbi_dir)
		print("moving to the next step...")
		return firmware_bin
	end

	-- making sure ./target exists first
	print("mkdir -p " .. c.projroot .. "target")

	local command = c.bsdir .. "build-sbi.sh " .. sbi_dir
	print("info: executing: " .. command)
	os.execute(command)

	return firmware_bin
end

---@return string[]
local function builduboot()
	local opensbi_bin = buildsbi() --- DEPENDENCY

	local uboot_dir = c.projroot .. "target/u-boot/"

	local spl = uboot_dir .. "spl/u-boot-spl"
	local itb = uboot_dir .. "u-boot.itb"

	if c.exists(spl) and c.exists(spl) then
		print("info: u-boot exists in " .. uboot_dir)
		print("moving to the next step...")
		return { spl, itb }
	end

	-- making sure ./target exists first
	print("mkdir -p " .. c.projroot .. "target")

	local command = c.bsdir .. "build-uboot.sh " .. uboot_dir .. " " .. opensbi_bin
	print("info: executing: " .. command)
	os.execute(command)

	return { spl, itb }
end

local function qemu()
	local deps = builduboot()
	os.execute("just runner-spl " .. deps[1] .. " " .. deps[2])
end

---@enum Target
local Target = {
	UBOOT = 1,
	OPENSBI = 2,
	QEMU = 3,
}

---@param target Target
---@return function
local function builder(target)
	if target == Target.UBOOT then
		return builduboot
	elseif target == Target.OPENSBI then
		return buildsbi
	elseif target == Target.QEMU then
		return qemu
	else
		-- we have exhaustive switch at home
		assert(false, "not all cases are handeled")
		os.exit(1)
	end
end

return {
	Target = Target,
	builder = builder,
}
