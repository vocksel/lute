local fs = require("@std/fs")
local path = require("@std/path")
local process = require("@std/process")

local function generate(): string
	return [==[
# lute bash completions

_lute() {
	local cur prev words cword
	if declare -f _init_completion > /dev/null 2>&1; then
		_init_completion || return
	else
		COMPREPLY=()
		cur="${COMP_WORDS[COMP_CWORD]}"
		prev="${COMP_WORDS[COMP_CWORD-1]}"
		words=("${COMP_WORDS[@]}")
		cword=$COMP_CWORD
	fi

	local commands="run check compile pkg test lint new doc setup transform completions"

	case "${words[1]}" in
		run)
			case "$prev" in
				--profile-output)
					_filedir '*.luau'
					return
					;;
				--frequency)
					return
					;;
			esac
			COMPREPLY=($(compgen -W "--profile --profile-output --frequency -h --help" -- "$cur"))
			if [[ "$cur" != -* ]] && [[ $cword -eq 2 ]]; then
				_filedir '*.luau'
			fi
			return
			;;
		check)
			COMPREPLY=($(compgen -W "-h --help" -- "$cur"))
			if [[ "$cur" != -* ]]; then
				_filedir '*.luau'
			fi
			return
			;;
		compile)
			case "$prev" in
				--output)
					_filedir
					return
					;;
			esac
			COMPREPLY=($(compgen -W "--output --bundle-stats --show-require-graph -h --help" -- "$cur"))
			if [[ "$cur" != -* ]] && [[ $cword -eq 2 ]]; then
				_filedir '*.luau'
			fi
			return
			;;
		pkg)
			case "${words[2]}" in
				auth)
					COMPREPLY=($(compgen -W "--token --domain" -- "$cur"))
					return
					;;
				run)
					if [[ "$cur" != -* ]] && [[ $cword -eq 3 ]]; then
						_filedir '*.luau'
					fi
					return
					;;
				*)
					if [[ $cword -eq 2 ]]; then
						COMPREPLY=($(compgen -W "install auth run" -- "$cur"))
					fi
					return
					;;
			esac
			;;
		test)
			case "${words[2]}" in
				snapshots)
					if [[ "$cur" != -* ]]; then
						_filedir -d
					fi
					return
					;;
				*)
					case "$prev" in
						-s|--suite|-c|--case)
							return
							;;
					esac
					COMPREPLY=($(compgen -W "snapshots --list -v --verbose -s --suite -c --case -i --interactive -u --update -h --help" -- "$cur"))
					return
					;;
			esac
			;;
		lint)
			case "$prev" in
				-c|--config|-r|--rules)
					_filedir
					return
					;;
			esac
			COMPREPLY=($(compgen -W "--auto-fix -c --config -h --help -j --json -r --rules -s --string-input -v --verbose --no-default-lints" -- "$cur"))
			if [[ "$cur" != -* ]]; then
				_filedir
			fi
			return
			;;
		doc)
			case "$prev" in
				-o|--output)
					_filedir -d
					return
					;;
				-m|--mapping)
					_filedir
					return
					;;
			esac
			COMPREPLY=($(compgen -W "-o --output -m --mapping -h --help" -- "$cur"))
			return
			;;
		setup)
			COMPREPLY=($(compgen -W "--with-luaurc -h --help" -- "$cur"))
			return
			;;
		new)
			COMPREPLY=($(compgen -W "-h --help" -- "$cur"))
			return
			;;
		transform)
			case "$prev" in
				-o|--output)
					_filedir
					return
					;;
			esac
			COMPREPLY=($(compgen -W "--dry-run -i --interactive -o --output -h --help" -- "$cur"))
			if [[ "$cur" != -* ]] && [[ $cword -eq 2 ]]; then
				_filedir '*.luau'
			fi
			return
			;;
		completions)
			if [[ $cword -eq 2 ]]; then
				COMPREPLY=($(compgen -W "zsh bash fish" -- "$cur"))
				return
			fi
			COMPREPLY=($(compgen -W "-i --install -h --help" -- "$cur"))
			return
			;;
		*)
			COMPREPLY=($(compgen -W "$commands" -- "$cur"))
			return
			;;
	esac
}

complete -F _lute lute
]==]
end

local function getInstallPath(): (path.Path, boolean)
	local home = process.homedir()
	local xdgDataHome = process.env["XDG_DATA_HOME"]
	if xdgDataHome and xdgDataHome ~= "" then
		local dir = path.join(xdgDataHome, "bash-completion/completions")
		if fs.exists(dir) then
			return path.join(dir, "lute"), false
		end
	end
	return path.join(home, ".local/share/bash-completion/completions/lute"), false
end

return {
	generate = generate,
	getInstallPath = getInstallPath,
}
