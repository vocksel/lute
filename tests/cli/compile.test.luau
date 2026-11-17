local fs = require("@std/fs")
local process = require("@std/process")
local path = require("@std/path")
local system = require("@std/system")
local test = require("@std/test")
local testutil = require("../testutil")

local COMPILER_CONTENTS = [[
local luau = require("@lute/luau")
local fs = require("@std/fs")

local args = { ... }
assert(#args == 2, "Expected one argument: path to Luau script to compile")

local handle = fs.open(args[2], "r")
local contents = fs.read(handle)
fs.close(handle)
luau.compile(contents)
print(`SUCCESS`)
]]

local COMPILEE_CONTENTS = [[return "Hello world"]]

local lutePath = process.execPath()
local tmpDir = system.tmpdir()

local function writeFile(filePath: path.Path, contents: string)
	fs.createDirectory(path.dirname(filePath), { makeParents = true })
	fs.writeStringToFile(filePath, contents)
end

test.suite("LuteCliCompile", function(suite)
	suite:case("runCompile", function(check)
		-- Setup
		-- Create files
		local compilerPath = path.join(tmpDir, "compiler.luau")
		local compilerFile = fs.open(compilerPath, "w+")
		fs.write(compilerFile, COMPILER_CONTENTS)
		fs.close(compilerFile)

		local compileePath = path.join(tmpDir, "compilee.luau")
		local compileeFile = fs.open(compileePath, "w+")
		fs.write(compileeFile, COMPILEE_CONTENTS)
		fs.close(compileeFile)

		local result = process.run({ path.format(lutePath), path.format(compilerPath), path.format(compileePath) })
		-- Compilation should work with no memory leaks
		check.eq(result.stderr, "")
		check.eq(testutil.normalizeLineEndings(result.stdout), "SUCCESS\n")
		check.eq(result.exitcode, 0)

		-- -- Cleanup
		fs.remove(compilerPath)
		fs.remove(compileePath)
	end)
	suite:case("compileProjectOutsideHome", function(check)
		-- The project sits outside the home folder, like a checkout in
		-- /workspaces, and requires a package from the Loom store in the home
		-- folder through a "~/" alias. The package resolves its own alias from
		-- its .config.luau.
		local workDir = path.join(tmpDir, "lute-compile-outside-home")
		if fs.exists(workDir) then
			fs.removeDirectory(workDir, { recursive = true })
		end

		local homeDir = path.join(workDir, "home")
		local packageDir = path.join(homeDir, ".loom", "store", "pkg")
		writeFile(
			path.join(packageDir, ".config.luau"),
			'return { luau = { aliases = { helpers = "./src/helpers" } } }\n'
		)
		writeFile(path.join(packageDir, "src", "init.luau"), 'return require("@helpers/greet")\n')
		writeFile(path.join(packageDir, "src", "helpers", "greet.luau"), 'return "hello from the store"\n')

		local projectDir = path.join(workDir, "project")
		writeFile(
			path.join(projectDir, ".config.luau"),
			'return { luau = { aliases = { pkg = "~/.loom/store/pkg/src" } } }\n'
		)
		writeFile(path.join(projectDir, "main.luau"), 'print(require("@pkg"))\n')

		local outputPath = path.join(workDir, if system.win32 then "main.exe" else "main")
		local env = setmetatable({
			HOME = path.format(homeDir),
			USERPROFILE = path.format(homeDir),
		}, { __index = process.env }) :: any

		local compileResult = process.run({
			path.format(lutePath),
			"compile",
			path.format(path.join(projectDir, "main.luau")),
			"--output",
			path.format(outputPath),
		}, { env = env })
		check.eq(compileResult.exitcode, 0)

		-- Runs with the real home folder, so "~/" can only resolve inside the bundle.
		local runResult = process.run({ path.format(outputPath) })
		check.eq(runResult.stderr, "")
		check.eq(testutil.normalizeLineEndings(runResult.stdout), "hello from the store\n")
		check.eq(runResult.exitcode, 0)

		fs.removeDirectory(workDir, { recursive = true })
	end)
end)
