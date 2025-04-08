#!/usr/bin/env lua
-- SPDX-License-Identifier: MIT

-- Get the directory of the current script
local script_path = debug.getinfo(1, "S").source:sub(2)
local script_dir = script_path:match("(.*/)")
-- Add script directory to package.path
package.path = script_dir .. "../?.lua;" -- .. package.path

local lib = require("build.lib")

-- HACK: adding a simple override here
local _, binary, cargo_arg0 = ...
if cargo_arg0 == "uboot" then
	require("build.steps.qemu").full(nil, binary)
	os.exit(0)
end

local commands = {
	lib.cmd("run-qemu", require("build.steps.qemu").simple, "Run the compiled kernel inside qemu"),
	lib.cmd("run-qemu-full", require("build.steps.qemu").full, "Run the compiled kernel with u-boot inside qemu"),
	lib.cmd("build-uboot", require("build.steps.uboot"), "Build OpenSBI"),
	lib.cmd("build-opensbi", require("build.steps.opensbi"), "Build OpenSBI"),
}

lib.evaluate(commands, ...)
