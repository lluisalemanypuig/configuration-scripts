# Name                           Code Equivalent
# black                          %F{black}   %F{0}
# red                            %F{red}     %F{1}
# green                          %F{green}   %F{2}
# yellow                         %F{yellow}  %F{3}
# blue                           %F{blue}    %F{4}
# magenta / purple               %F{magenta} %F{5}
# cyan                           %F{cyan}    %F{6}
# white                          %F{white}   %F{7}
# gray / grey / light-black                  %F{8}
# light-red / bright-red                     %F{9}
# light-green / bright-green                 %F{10}
# light-yellow / bright-yellow               %F{11}
# light-blue / bright-blue                   %F{12}
# light-magenta / bright-magenta             %F{13}
# light-cyan / bright-cyan                   %F{14}
# bright-white                               %F{15}

autoload -Uz vcs_info

+vi-git-ahead-behind() {
    # vcs_info runs this hook once per format, and only a format with %m can show the result.
    [[ $2 == *%*m* ]] || return 0

    local prefix_and_upstream prefix entry
    local -i untracked unstaged staged is_rename_source
    local -a gitstatus ahead_behind status_entries

    prefix_and_upstream=$(git rev-parse --show-prefix '@{upstream}' 2>/dev/null) || return 0
    prefix=${prefix_and_upstream%$'\n'*}

    status_entries=(${(0)"$(git status --porcelain -z --untracked-files=all 2>/dev/null)"})

    # Untracked files are counted below the current directory only; changes to tracked files are
    # counted across the whole repository.
    for entry in "${status_entries[@]}"; do
        if (( is_rename_source )); then
            is_rename_source=0
            continue
        fi
        [[ $entry == [RC]* || $entry == ?[RC]* ]] && is_rename_source=1
        [[ $entry == "?? $prefix"* ]] && (( ++untracked ))
        [[ $entry == ?[MD]* ]] && (( ++unstaged ))
        [[ $entry == [MADRC]* ]] && (( ++staged ))
    done

    ahead_behind=($(git rev-list --left-right --count 'HEAD...@{upstream}' 2>/dev/null))

    (( untracked > 0 ))       && gitstatus+=("%F{magenta}?${untracked}%f")
    (( unstaged > 0 ))        && gitstatus+=("%F{red}*${unstaged}%f")
    (( staged > 0 ))          && gitstatus+=("%F{blue}+${staged}%f")
    (( ahead_behind[1] > 0 )) && gitstatus+=("%F{10}⇡${ahead_behind[1]}%f")
    (( ahead_behind[2] > 0 )) && gitstatus+=("%F{9}⇣${ahead_behind[2]}%f")

    hook_com[misc]="${(j: :)gitstatus}"
}

local PROMPT_START="%{\e]133;A\a%}"
local PROMPT_END="%{\e]133;B\a%}"

setopt PROMPT_SUBST

zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git*+set-message:*' hooks git-ahead-behind
zstyle ':vcs_info:*' max-exports 2
zstyle ':vcs_info:git:*' formats '%b' '%m'

precmd() {
	vcs_info

	local branch="${vcs_info_msg_0_}"
	local status_head="${vcs_info_msg_1_}"

	local PROMPT_STRING=""
	local ARROW_PROMPT="%F{15}➜ "

	if [[ -z $branch ]]; then
		PROMPT_STRING="%F{green}%n %F{cyan}%~ %f"
	else
		GIT_DISPLAY="%F{yellow}[$branch%f"
		if [[ -n $status_head ]]; then
			GIT_DISPLAY+=" $status_head"
		fi
		GIT_DISPLAY+="%F{yellow}]%f"
		PROMPT_STRING="%F{green}%n %F{cyan}%~ ${GIT_DISPLAY}%F{green}%f"
	fi

	PROMPT="${PROMPT_STRING}"$'\n'"${ARROW_PROMPT}"
	RPROMPT=$'%{\e[1A%}%F{gray}%D{%H:%M:%S %a %-d %b %Y}%f%{\e[1B%}'
}
