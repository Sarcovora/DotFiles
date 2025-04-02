# CodeWhisperer pre block. Keep at the top of this file.
# [[ -f "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.pre.zsh"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# MacOS only
eval "$(/opt/homebrew/bin/brew shellenv)"

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Snippets (OMZP:: is name space for Oh My Zsh plugins)
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins
zinit snippet OMZP::git
zinit snippet OMZP::conda
zinit snippet OMZP::ssh
zinit snippet OMZP::thefuck
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no

# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no

# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'

zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza --color $realpath'

# Keybindings
bindkey '^y' autosuggest-accept
bindkey '^p' history-search-backward # allows search autocompletion of current prefix only
bindkey '^n' history-search-forward

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/ekuo/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/ekuo/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/ekuo/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/ekuo/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

conda config --set auto_activate_base false

# history
HISTFILE='/Users/ekuo/.zsh_history_zen'
HISTSIZE=999999
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_find_no_dups

export EDITOR='nvim'
export VISUAL='nvim'

# ls aliases
alias l='eza -lah'
alias la='eza -lAh'
alias ll='eza -lh'
alias ls='eza -G'

# program aliases
alias lg='lazygit'

alias z='__zoxide_z'
alias zi='__zoxide_zi'

alias v='nvim'
alias nv='NO_AUTO_SESSION=1 nvim' # no auto-session vim

alias bat='bat -A'

alias ca='conda activate'

alias p='procs'

alias nf='neofetch'

alias savelife='~/LifeVault/.commit_push.bash'
alias sl='~/LifeVault/.commit_push.bash'
alias lifepull='~/LifeVault/.pull.bash'
alias lgst='~/LifeVault/.gstatus.bash'

alias src='source ~/.zshrc'

# tmux
alias tl='tmux ls'
alias tn='tmux new -s'
alias ta='tmux a -t'

# functions
yy () {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" 
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")"  && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]
	then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

tt () {
    local session
    session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | head -n1)
    if [ -n "$session" ]; then
        tmux attach-session -t "$session"
    else
        echo "No tmux sessions found :("
    fi
}

# Shell Integrations
eval "$(zoxide init zsh)"
eval $(thefuck --alias)

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# VARS
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/nitishgupta/.mujoco/mujoco210/bin
# export MUJOCO_PY_MJPRO_PATH=~/.mujoco/mujoco200
# export MUJOCO_PY_MJKEY_PATH=~/.mujoco/mjkey.txt

# PATH
PATH=~/.console-ninja/.bin:$PATH

# CodeWhisperer post block. Keep at the bottom of this file.
# [[ -f "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.post.zsh"
export PATH="/usr/local/opt/mysql-client/bin:$PATH"
