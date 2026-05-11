local fs = require("@std/fs")
local path = require("@std/path")
local process = require("@std/process")

local function generate(): string
	return [=[
#compdef lute

_lute_pkg() {
	local -a pkg_commands
	pkg_commands=(
		'install:Install dependencies from loom.config.luau'
		'auth:Save authentication credentials'
		'run:Package-aware script runner'
	)

	_arguments -C \
		'1: :->subcommand' \
		'*:: :->subargs'

	case $state in
		subcommand)
			_describe 'pkg subcommand' pkg_commands
			;;
		subargs)
			case $words[1] in
				auth)
					_arguments \
						'--token=[Authentication token]:token' \
						'--domain=[Package registry domain]:domain'
					;;
				run)
					_arguments ':script:_files -g "*.luau"'
					;;
			esac
			;;
	esac
}

_lute_test() {
	local -a test_commands
	test_commands=('snapshots:Run snapshot tests')

	_arguments -C \
		'--list[List all tests without running]' \
		'(-v --verbose)'{-v,--verbose}'[Run tests verbosely]' \
		'(-s --suite)'{-s,--suite}'[Run only named suite]:suite' \
		'(-c --case)'{-c,--case}'[Run only matching test cases]:case' \
		'(-i --interactive)'{-i,--interactive}'[Interactively accept/reject snapshot changes]' \
		'(-u --update)'{-u,--update}'[Auto-accept all snapshot changes]' \
		'(-h --help)'{-h,--help}'[Show help]' \
		'1: :->subcommand' \
		'*:: :->subargs'

	case $state in
		subcommand)
			_describe 'test subcommand' test_commands
			;;
		subargs)
			case $words[1] in
				snapshots)
					_arguments '*:path:_files -/'
					;;
			esac
			;;
	esac
}

_lute() {
	local -a commands
	commands=(
		'run:Run a Luau script'
		'check:Type-check Luau files'
		'compile:Compile a script to a standalone executable'
		'pkg:Package management'
		'test:Run tests'
		'lint:Lint Luau files'
		'new:Create a new project'
		'doc:Generate documentation'
		'setup:Generate type definition files'
		'transform:Run code transformations'
		'completions:Generate shell completions'
	)

	_arguments -C \
		'(-h --help)'{-h,--help}'[Show help]' \
		'--version[Show version]' \
		'1: :->command' \
		'*:: :->args'

	case $state in
		command)
			_describe 'lute command' commands
			;;
		args)
			case $words[1] in
				run)
					_arguments \
						'--profile[Enable profiling]' \
						'--profile-output=[Profile output file]:file:_files' \
						'--frequency=[Sampling frequency in Hz]:hz' \
						'(-h --help)'{-h,--help}'[Show help]' \
						':script:_files -g "*.luau"'
					;;
				check)
					_arguments \
						'(-h --help)'{-h,--help}'[Show help]' \
						'*:file:_files -g "*.luau"'
					;;
				compile)
					_arguments \
						'--output=[Output executable path]:path:_files' \
						'--bundle-stats[Display bundle size statistics]' \
						'--show-require-graph[Print require dependency graph]' \
						'(-h --help)'{-h,--help}'[Show help]' \
						':entry:_files -g "*.luau"'
					;;
				pkg)
					_lute_pkg
					;;
				test)
					_lute_test
					;;
				lint)
					_arguments \
						'(-h --help)'{-h,--help}'[Show help]' \
						'(-v --verbose)'{-v,--verbose}'[Enable verbose output]' \
						'(-c --config)'{-c,--config}'[Config file path]:path:_files' \
						'(-j --json)'{-j,--json}'[Output JSON format]' \
						'(-r --rules)'{-r,--rules}'[Path to lint rule or folder]:path:_files' \
						'(-s --string-input)'{-s,--string-input}'[Lint string input instead of files]' \
						'--auto-fix[Automatically apply fixes]' \
						'--no-default-lints[Disable default lint rules]' \
						'*:path:_files'
					;;
				doc)
					_arguments \
						'(-o --output)'{-o,--output}'[Output directory]:dir:_files -/' \
						'(-m --mapping)'{-m,--mapping}'[Custom mapping file]:file:_files' \
						'(-h --help)'{-h,--help}'[Show help]' \
						'*:module path:_files'
					;;
				setup)
					_arguments \
						'--with-luaurc[Also write .luaurc in current directory]' \
						'(-h --help)'{-h,--help}'[Show help]'
					;;
				new)
					_arguments \
						'(-h --help)'{-h,--help}'[Show help]' \
						':project name'
					;;
				transform)
					_arguments \
						'--dry-run[Preview changes without writing]' \
						'(-i --interactive)'{-i,--interactive}'[Interactive mode with previews]' \
						'(-o --output)'{-o,--output}'[Write to single file]:file:_files' \
						'(-h --help)'{-h,--help}'[Show help]' \
						':migration path:_files -g "*.luau"' \
						'*:file:_files'
					;;
				completions)
					_arguments \
						'(-i --install)'{-i,--install}'[Write to standard shell location]' \
						'(-h --help)'{-h,--help}'[Show help]' \
						':shell:(zsh bash fish)'
					;;
			esac
			;;
	esac
}

_lute "$@"
]=]
end

-- Returns (installPath, needsFpathNote).
-- needsFpathNote is true when the chosen directory is not already in $fpath.
local function getInstallPath(): (path.Path, boolean)
	local homebrewPrefix = process.env["HOMEBREW_PREFIX"]
	if homebrewPrefix and homebrewPrefix ~= "" then
		local dir = path.join(homebrewPrefix, "share/zsh/site-functions")
		if fs.exists(dir) then
			return path.join(dir, "_lute"), false
		end
	end

	local home = process.homedir()
	if fs.exists(path.join(home, ".oh-my-zsh")) then
		return path.join(home, ".oh-my-zsh/completions/_lute"), false
	end

	return path.join(home, ".zsh/completions/_lute"), true
end

return {
	generate = generate,
	getInstallPath = getInstallPath,
}
