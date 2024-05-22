
# Add `~/bin` to the `$PATH`
export PATH="$HOME/Library/Python/3.10/bin:$HOME/bin:$PATH";
export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
export FZF_DEFAULT_COMMAND='find . -path './.git' -prune -o -print'
# # Load the shell dotfiles, and then some:
# # * ~/.path can be used to extend `$PATH`.
# # * ~/.extra can be used for other settings you don’t want to commit.
# for file in ~/.{path,bash_prompt,exports,aliases,functions,extra}; do
# 	[ -r "$file" ] && [ -f "$file" ] && source "$file";
# done;
# unset file;
source ~/.aliases
source ~/.exports


# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob;

# Append to the Bash history file, rather than overwriting it
shopt -s histappend;

# Autocorrect typos in path names when using `cd`
shopt -s cdspell;

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
	shopt -s "$option" 2> /dev/null;
done;

# Add tab completion for many Bash commands
if which brew &> /dev/null && [ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]; then
	# Ensure existing Homebrew v1 completions continue to work
	export BASH_COMPLETION_COMPAT_DIR="/opt/homebrew/etc/bash_completion.d";
#	source "$(brew --prefix)/etc/profile.d/bash_completion.sh";
elif [ -f /etc/bash_completion ]; then
	source /etc/bash_completion;
fi;

# Enable tab completion for `g` by marking it as an alias for `git`
if type _git &> /dev/null; then
	complete -o default -o nospace -F _git g;
fi;

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
#[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;

# Add tab completion for `defaults read|write NSGlobalDomain`
# You could just use `-g` instead, but I like being explicit
#complete -W "NSGlobalDomain" defaults;
#
## Add `killall` tab completion for common apps
#complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal" killall;
#eval "$(/opt/homebrew/bin/brew shellenv)"

##load-nvmrc() {
##  local node_version="$(nvm version)"
##  local nvmrc_path="$(nvm_find_nvmrc)"
##
##  if [ -n "$nvmrc_path" ]; then
##    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")
##
##    if [ "$nvmrc_node_version" = "N/A" ]; then
##      nvm install
##    elif [ "$nvmrc_node_version" != "$node_version" ]; then
##      nvm use 
##    fi
##  elif [ "$node_version" != "$(nvm version default)" ]; then
##    nvm use default
##  fi
##}
##if [ -s "$HOME/.nvm/nvm.sh" ]; then
##  export NVM_DIR="$HOME/.nvm"
##  nvm_cmds=(nvm node npm yarn nvim)
##  for cmd in $nvm_cmds ; do
##    alias $cmd="unalias $nvm_cmds && unset nvm_cmds && . $NVM_DIR/nvm.sh --no-use && load-nvmrc && $cmd"
##  done
##fi
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm



if [ -f "/home/linuxbrew/.linuxbrew/opt/bash-git-prompt/share/gitprompt.sh" ]; then
    __GIT_PROMPT_DIR="/home/linuxbrew/.linuxbrew/opt/bash-git-prompt/share"
    source "/home/linuxbrew/.linuxbrew/opt/bash-git-prompt/share/gitprompt.sh"
fi

if [ -f "/opt/homebrew/opt/bash-git-prompt/share/gitprompt.sh" ]; then
    __GIT_PROMPT_DIR="/opt/homebrew/opt/bash-git-prompt/share"
    source "/opt/homebrew/opt/bash-git-prompt/share/gitprompt.sh"
fi

load-sdk(){
	#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
	export SDKMAN_DIR="$HOME/.sdkman"
	[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
} 
alias sdk="load-sdk && sdk"

if [ -n "$NVIM" ]; then
	#if [ -x "$(command -v nvr)" ]; then
		#alias nvim=nvr
		export VISUAL="nvr -cc split --remote-wait +'set bufhidden=wipe'"

	#else
else
	export VISUAL="nvim"
fi

set -o vi
#neofetch --off
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

