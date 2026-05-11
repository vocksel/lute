local fs = require("@std/fs")
local path = require("@std/path")
local process = require("@std/process")

local function generate(): string
	return [==[
# lute fish completions

set -l __lute_subcommands run check compile pkg test lint new doc setup transform completions

# Top-level commands
complete -c lute -f -n 'not __fish_seen_subcommand_from $__lute_subcommands' -a run         -d 'Run a Luau script'
complete -c lute -f -n 'not __fish_seen_subcommand_from $__lute_subcommands' -a check       -d 'Type-check Luau files'
complete -c lute -f -n 'not __fish_seen_subcommand_from $__lute_subcommands' -a compile     -d 'Compile a script to a standalone executable'
complete -c lute -f -n 'not __fish_seen_subcommand_from $__lute_subcommands' -a pkg         -d 'Package management'
complete -c lute -f -n 'not __fish_seen_subcommand_from $__lute_subcommands' -a test        -d 'Run tests'
complete -c lute -f -n 'not __fish_seen_subcommand_from $__lute_subcommands' -a lint        -d 'Lint Luau files'
complete -c lute -f -n 'not __fish_seen_subcommand_from $__lute_subcommands' -a new         -d 'Create a new project'
complete -c lute -f -n 'not __fish_seen_subcommand_from $__lute_subcommands' -a doc         -d 'Generate documentation'
complete -c lute -f -n 'not __fish_seen_subcommand_from $__lute_subcommands' -a setup       -d 'Generate type definition files'
complete -c lute -f -n 'not __fish_seen_subcommand_from $__lute_subcommands' -a transform   -d 'Run code transformations'
complete -c lute -f -n 'not __fish_seen_subcommand_from $__lute_subcommands' -a completions -d 'Generate shell completions'

# Global flags (only before any subcommand)
complete -c lute -f -n 'not __fish_seen_subcommand_from $__lute_subcommands' -s h -l help    -d 'Show help'
complete -c lute -f -n 'not __fish_seen_subcommand_from $__lute_subcommands'      -l version -d 'Show version'

# run
complete -c lute -n '__fish_seen_subcommand_from run' -l profile        -d 'Enable profiling'
complete -c lute -n '__fish_seen_subcommand_from run' -l profile-output -d 'Profile output file' -r
complete -c lute -n '__fish_seen_subcommand_from run' -l frequency      -d 'Sampling frequency in Hz' -r
complete -c lute -n '__fish_seen_subcommand_from run' -s h -l help      -d 'Show help'

# check
complete -c lute -n '__fish_seen_subcommand_from check' -s h -l help -d 'Show help'

# compile
complete -c lute -n '__fish_seen_subcommand_from compile' -l output             -d 'Output executable path' -r
complete -c lute -n '__fish_seen_subcommand_from compile' -l bundle-stats       -d 'Display bundle size statistics'
complete -c lute -n '__fish_seen_subcommand_from compile' -l show-require-graph -d 'Print require dependency graph'
complete -c lute -n '__fish_seen_subcommand_from compile' -s h -l help          -d 'Show help'

# pkg subcommands
complete -c lute -f -n '__fish_seen_subcommand_from pkg; and not __fish_seen_subcommand_from install auth run' \
	-a install -d 'Install dependencies from loom.config.luau'
complete -c lute -f -n '__fish_seen_subcommand_from pkg; and not __fish_seen_subcommand_from install auth run' \
	-a auth -d 'Save authentication credentials'
complete -c lute -f -n '__fish_seen_subcommand_from pkg; and not __fish_seen_subcommand_from install auth run' \
	-a run -d 'Package-aware script runner'

# pkg auth flags
complete -c lute -n '__fish_seen_subcommand_from pkg; and __fish_seen_subcommand_from auth' \
	-l token  -d 'Authentication token' -r
complete -c lute -n '__fish_seen_subcommand_from pkg; and __fish_seen_subcommand_from auth' \
	-l domain -d 'Package registry domain' -r

# test subcommands and flags
complete -c lute -f -n '__fish_seen_subcommand_from test; and not __fish_seen_subcommand_from snapshots' \
	-a snapshots -d 'Run snapshot tests'
complete -c lute -n '__fish_seen_subcommand_from test' -l list             -d 'List all tests without running'
complete -c lute -n '__fish_seen_subcommand_from test' -s v -l verbose     -d 'Run tests verbosely'
complete -c lute -n '__fish_seen_subcommand_from test' -s s -l suite       -d 'Run only named suite' -r
complete -c lute -n '__fish_seen_subcommand_from test' -s c -l case        -d 'Run only matching test cases' -r
complete -c lute -n '__fish_seen_subcommand_from test' -s i -l interactive -d 'Interactively accept/reject snapshot changes'
complete -c lute -n '__fish_seen_subcommand_from test' -s u -l update      -d 'Auto-accept all snapshot changes'
complete -c lute -n '__fish_seen_subcommand_from test' -s h -l help        -d 'Show help'

# lint flags
complete -c lute -n '__fish_seen_subcommand_from lint' -l auto-fix          -d 'Automatically apply fixes'
complete -c lute -n '__fish_seen_subcommand_from lint' -s c -l config       -d 'Config file path' -r
complete -c lute -n '__fish_seen_subcommand_from lint' -s h -l help         -d 'Show help'
complete -c lute -n '__fish_seen_subcommand_from lint' -s j -l json         -d 'Output JSON format'
complete -c lute -n '__fish_seen_subcommand_from lint' -s r -l rules        -d 'Path to lint rule or folder' -r
complete -c lute -n '__fish_seen_subcommand_from lint' -s s -l string-input -d 'Lint string input instead of files'
complete -c lute -n '__fish_seen_subcommand_from lint' -s v -l verbose      -d 'Enable verbose output'
complete -c lute -n '__fish_seen_subcommand_from lint' -l no-default-lints  -d 'Disable default lint rules'

# doc flags
complete -c lute -n '__fish_seen_subcommand_from doc' -s o -l output  -d 'Output directory' -r
complete -c lute -n '__fish_seen_subcommand_from doc' -s m -l mapping -d 'Custom mapping file' -r
complete -c lute -n '__fish_seen_subcommand_from doc' -s h -l help    -d 'Show help'

# setup flags
complete -c lute -n '__fish_seen_subcommand_from setup' -l with-luaurc -d 'Also write .luaurc in current directory'
complete -c lute -n '__fish_seen_subcommand_from setup' -s h -l help   -d 'Show help'

# new flags
complete -c lute -n '__fish_seen_subcommand_from new' -s h -l help -d 'Show help'

# transform flags
complete -c lute -n '__fish_seen_subcommand_from transform' -l dry-run          -d 'Preview changes without writing'
complete -c lute -n '__fish_seen_subcommand_from transform' -s i -l interactive -d 'Interactive mode with previews'
complete -c lute -n '__fish_seen_subcommand_from transform' -s o -l output      -d 'Write to single file' -r
complete -c lute -n '__fish_seen_subcommand_from transform' -s h -l help        -d 'Show help'

# completions subcommand
complete -c lute -f -n '__fish_seen_subcommand_from completions' -a 'zsh bash fish'
complete -c lute    -n '__fish_seen_subcommand_from completions' -s i -l install -d 'Write to standard shell location'
complete -c lute    -n '__fish_seen_subcommand_from completions' -s h -l help    -d 'Show help'
]==]
end

local function getInstallPath(): (path.Path, boolean)
	local home = process.homedir()
	local xdgConfigHome = process.env["XDG_CONFIG_HOME"]
	if xdgConfigHome and xdgConfigHome ~= "" then
		local dir = path.join(xdgConfigHome, "fish/completions")
		if fs.exists(dir) then
			return path.join(dir, "lute.fish"), false
		end
	end
	return path.join(home, ".config/fish/completions/lute.fish"), false
end

return {
	generate = generate,
	getInstallPath = getInstallPath,
}
