local cli = require("@batteries/cli")
local fs = require("@std/fs")
local path = require("@std/path")
local process = require("@std/process")

local bash = require("@self/shells/bash")
local fish = require("@self/shells/fish")
local zsh = require("@self/shells/zsh")

type ShellModule = {
	generate: () -> string,
	getInstallPath: () -> (path.Path, boolean),
}

local shells: { [string]: ShellModule } = {
	zsh = zsh,
	bash = bash,
	fish = fish,
}

local USAGE = "Usage: lute completions <shell> [--install]"

local function printHelp()
	print(USAGE)
	print([=[
Generate a shell completion script for lute and print it to stdout.

ARGUMENTS:
  <shell>    Shell to generate completions for. One of: zsh, bash, fish

OPTIONS:
  -i, --install    Write the completion script to the standard location for
                   the given shell instead of printing to stdout
  -h, --help       Show this help message

EXAMPLES:
  lute completions zsh > ~/.zfunc/_lute
  eval "$(lute completions bash)"
  lute completions fish --install

INSTALL LOCATIONS:
  zsh     Auto-detected: $HOMEBREW_PREFIX/share/zsh/site-functions/_lute,
          ~/.oh-my-zsh/completions/_lute, or ~/.zsh/completions/_lute
  bash    ~/.local/share/bash-completion/completions/lute
  fish    ~/.config/fish/completions/lute.fish
]=])
end

local function install(shell: string, shellModule: ShellModule)
	local installPath, needsFpathNote = shellModule.getInstallPath()
	local dir = path.dirname(installPath)
	if not fs.exists(dir) then
		fs.createDirectory(dir)
	end
	fs.writeStringToFile(installPath, shellModule.generate())
	print(`Wrote {shell} completions to {path.format(installPath)}`)
	if needsFpathNote then
		print("")
		print("To enable completions, add the following to your ~/.zshrc:")
		print("  fpath=(~/.zsh/completions $fpath)")
		print("  autoload -Uz compinit && compinit")
	end
end

local function main(...: string)
	local args = cli.parser()
	args:add("shell", "positional", { help = "Shell to generate completions for (zsh, bash, fish)" })
	args:add("install", "flag", { help = "Write to the standard shell completions location", aliases = { "i" } })
	args:add("help", "flag", { help = "Show this help message", aliases = { "h" } })
	args:parse({ ... })

	if args:has("help") or not args:get("shell") then
		printHelp()
		return
	end

	local shell = args:get("shell")
	assert(shell)

	local shellModule = shells[shell]
	if not shellModule then
		print(`Error: Unknown shell '{shell}'. Supported shells: zsh, bash, fish`)
		process.exit(1)
		return
	end

	if args:has("install") then
		install(shell, shellModule)
	else
		print(shellModule.generate())
	end
end

main(...)
