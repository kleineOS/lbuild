-- SPDX-License-Identifier: MIT

local c = require("build.common")

local version = "v1.6"
local repo = "https://github.com/riscv-software-src/opensbi.git"

local target = c.projroot .. "target/opensbi/"
local output = target .. "build/platform/generic/firmware/fw_dynamic.bin"

local makecmd = "make -C " .. target .. " -j$(nproc) PLATFORM=generic CROSS_COMPILE=riscv64-linux-gnu-"

---@return string string path to the fw_dynamic.bin
local function full()
	-- early exit if we have what we need
	if c.exists(output) then
		return output
	end

	if not c.exists(target) then
		print("info: fetching source using git from " .. repo)
		c.gitclone(repo, version, target)
	else
		print("info: source found, skipping fetch")
	end

	print("info: executing command: " .. makecmd)
	os.execute(makecmd)

	if not c.exists(output) then
		print("error: could not find output: " .. output)
		os.exit(1)
	end

	return output
end

return full
