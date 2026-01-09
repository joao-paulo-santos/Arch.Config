export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"
ZSH_DIR="${ZDOTDIR:-$HOME}/.config/zsh"

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
