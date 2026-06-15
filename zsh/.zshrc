export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"
ZSH_DIR="${ZDOTDIR:-$HOME}/.config/zsh"

fpath=(~/.zfunc $fpath)
autoload -Uz compinit && compinit
# CASE_SENSITIVE="true"
# HYPHEN_INSENSITIVE="true"

# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# DISABLE_LS_COLORS="true"

# DISABLE_AUTO_TITLE="true"

# ENABLE_CORRECTION="true"

# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# COMPLETION_WAITING_DOTS="true"

# DISABLE_UNTRACKED_FILES_DIRTY="true"

# HIST_STAMPS="dd/mm/yyyy"

# ZSH_CUSTOM=/path/to/new-custom-folder

plugins=(git)

source $ZSH/oh-my-zsh.sh

alias cd..="cd .."
alias cd...="cd ../.."
alias cd....="cd ../../.."
alias hmenu='/mnt/prometheus/Dev/Repos/hypr-tofi/build/hypr-tofi'

# start hyprland
if [[ "$(tty)" == "/dev/tty1" && -z "$(pidof Xwayland)" && -z "$(pidof sway)" && -z "$(pidof hyprland)" ]]; then
    exec Hyprland
fi

# Zoxide config
if [[ -f "$ZSH_DIR/.zsh_zoxide" ]]; then
  source "$ZSH_DIR/.zsh_zoxide"
fi

eval "$(zoxide init zsh)"

# enable vi editing mode
bindkey -v

# optional: make the vi command-mode timeout shorter so Esc is responsive
# (value in tenths of a second; 10 = 1s)
KEYTIMEOUT=10
export KEYTIMEOUT

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
export PATH="$HOME/.local/bin:$PATH"
eval "$(tv init zsh)"

# Terminal emulator
export TERMINAL="kitty"

# bun completions
[ -s "/home/ecila/.bun/_bun" ] && source "/home/ecila/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
