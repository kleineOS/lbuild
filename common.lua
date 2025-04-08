-- SPDX-License-Identifier: MIT

---@return string
local function bsdir()
	local script_path = debug.getinfo(1, "S").source:sub(2)
	local script_dir = script_path:match("(.*/)")
	return script_dir
end

---@return string
local function projroot()
	local root = os.getenv("CARGO_MANIFEST_DIR")
	if root == nil then
		-- root = "./"
		local pwd = os.getenv("PWD")
		if pwd == nil then
			print("error: $PWD is unset")
			os.exit(1)
		end
		root = pwd .. "/"
	else
		root = root .. "/"
	end

	-- more safety checks cos I am paranoid
	if root == "/" then
		print("error: projdir seems to be /, this is not supported!")
		os.exit(1)
	end

	return root
end

---@param file string
---@return boolean
local function exists(file)
	local f = io.open(file, "r")
	if f ~= nil then
		io.close(f)
		return true
	else
		return false
	end
end

-- Function to check if a substring exists within a string
-- @param str The string to search within
-- @param substr The substring to search for
-- @return True if the substring is found, false otherwise
local function contains(str, substr)
	return string.find(str, substr, 1, true) ~= nil
end

---@param remote string
---@param branch string
---@param target string?
---@return boolean boolean true if success
local function gitclone(remote, branch, target)
	if target == nil then
		target = ""
	end

	local command = string.format("git clone --depth 1 -b %s %s %s", branch, remote, target)

	local success, code, i = os.execute(command)

	if not success then
		print(string.format("error: gitclone error: %s %d", code, i))
		return false
	end

	return true
end

---@param cmd string
local function execute(cmd)
	local success, error, code = os.execute(cmd)

	if not success then
		print("an error occured when executing:\n" .. cmd .. "\n")
		print("more info:")
		if error == "exit" then
			print("error: command exited with the status code " .. code)
		elseif error == "signal" then
			print("error: recieved signal " .. code .. "to terminate the command")
		end
		os.exit(1)
	end
end

---@param table1 table
---@param table2 table
local function concatt(table1, table2)
	for i = 1, #table2 do
		table1[#table1 + 1] = table2[i]
	end
end

return {
	-- common variables
	bsdir = bsdir(),
	projroot = projroot(),
	-- common functions
	exists = exists,
	gitclone = gitclone,
	contains = contains,
	execute = execute,
	concatt = concatt,
}
