#!/bin/bash

# Function to install zsh if not already installed
install_zsh() {
  if ! command -v zsh &> /dev/null; then
    echo "zsh not found. Installing zsh..."
    sudo apt-get update && sudo apt-get install -y zsh
  else
    echo "zsh is already installed."
  fi
}

# Function to change the default shell to zsh for the current user
change_default_shell_to_zsh() {
  if [ "$SHELL" != "$(which zsh)" ]; then
    echo "Changing default shell to zsh..."
    chsh -s "$(which zsh)"
  else
    echo "Default shell is already zsh."
  fi
}

# Install zsh
install_zsh

# Change default shell to zsh
change_default_shell_to_zsh

# Define repositories to clone
repos=(
  "https://kkgithub.com/zsh-users/zsh-syntax-highlighting.git"
  "https://kkgithub.com/zsh-users/zsh-autosuggestions.git"
  "https://kkgithub.com/agkozak/zsh-z.git"
  "https://kkgithub.com/marlonrichert/zsh-autocomplete.git"
  "https://kkgithub.com/romkatv/powerlevel10k.git"
)

# Create ~/.terminal directory if it doesn't exist
mkdir -p ~/.terminal

# Clone repositories
for repo in "${repos[@]}"; do
  git clone "$repo" ~/.terminal/$(basename "$repo" .git)
done

# Write content to ~/.zshrc
cat << 'EOF' > ~/.zshrc
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Alias
alias vi='vim'
alias ls='ls --color=auto'
alias la='ls -la --color=auto'
alias md='mkdir'
alias c='clear'
alias ..='cd ..'
alias ~='cd ~'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias ping='ping -c 4'
alias rm='rm -I --preserve-root'
alias mv='mv -i'
alias cp='cp -i'
alias ln='ln -i'

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/max/.zshrc'

# Plugins
source ~/.terminal/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.terminal/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.terminal/zsh-z/zsh-z.plugin.zsh
source ~/.terminal/zsh-autocomplete/zsh-autocomplete.plugin.zsh
source ~/.terminal/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF

# Source the new .zshrc to apply changes
source ~/.zshrc
