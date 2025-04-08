-- SPDX-License-Identifier: MIT

local c = require("build.common")
local opensbi_step = require("build.steps.opensbi")

local version = "v2025.01"
local repo = "https://source.denx.de/u-boot/u-boot.git"

local uboot_dir = c.projroot .. "target/u-boot/"
local spl = uboot_dir .. "spl/u-boot-spl"
local itb = uboot_dir .. "u-boot.itb"

local outputs = { spl, itb }

local makeconfig = "make -C " .. uboot_dir .. " qemu-riscv64_spl_defconfig"
local makecmd = "make -C " .. uboot_dir .. " -j$(nproc) CROSS_COMPILE=riscv64-linux-gnu-"

---@return string[]
local function full()
	-- early exit if we have what we need
	if c.exists(outputs[1]) and c.exists(outputs[2]) then
		return outputs
	end

	--- ======== DEPENDENCY ========
	local opensbi = opensbi_step()
	makecmd = makecmd .. " OPENSBI=" .. opensbi
	--- ====== END DEPENDENCY ======

	if not c.contains(makecmd, "fw_dynamic.bin") then
		print("error: makecmd does not have fw_dynamic.bin: " .. makecmd)
		os.exit(1)
	end

	if not c.exists(uboot_dir) then
		print("info: fetching source using git from " .. repo)
		c.gitclone(repo, version, uboot_dir)
	else
		print("info: source found, skipping fetch")
	end

	print("info: executing command: " .. makeconfig)
	os.execute(makeconfig)
	print("info: executing command: " .. makecmd)
	os.execute(makecmd)

	for _, out in ipairs(outputs) do
		if not c.exists(out) then
			print("error: could not find output: " .. out)
			os.exit(1)
		end
	end

	return outputs
end

return full
