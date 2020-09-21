#!/usr/bin/env zsh

set -euo pipefail

install_homebrew() {
  git clone https://github.com/Homebrew/brew.git /tmp/brew
  sudo mv -f /tmp/brew /opt/brew
}

install_packages() {
  /opt/brew/bin/brew install chruby \
                             jq \
                             pyenv \
                             reattach-to-user-namespace \
                             ruby-install \
                             stow \
                             tmux \
                             tree \
                             vim \
                             zsh \
                             zsh-autosuggestions \
                             zsh-history-substring-search \
                             zsh-syntax-highlighting

  /opt/brew/bin/brew cask install hammerspoon \
                                  insomnia \
                                  insomnia-designer
}

install_dotfiles() {
  mkdir -p "${HOME}/Projects"

  if [ -d "${HOME}/Projects/dotfiles" ]; then
    pushd "${HOME}/Projects/dotfiles"
    /usr/bin/git pull
    popd
  else
    /usr/bin/git clone https://github.com/htp/dotfiles.git "${HOME}/Projects/dotfiles"
  fi

  for directory in ${HOME}/Projects/dotfiles/*/; do
    local package="${${directory%/*}##*/}"
    /opt/brew/bin/stow --dir "${HOME}/Projects/dotfiles" --target "${HOME}" --restow "${package}"
  done
}

install_latest_ruby() {
  /opt/brew/bin/ruby-install ruby
}

install_latest_python() {
  /opt/brew/bin/pyenv install "$(pyenv install --list | sed -E "s/^ +//" | grep "^[0-9].[0-9].[0-9]$" | sort --reverse | head -n 1)"
}

main() {
  install_homebrew
  install_packages
  install_dotfiles
  install_latest_ruby
  install_latest_python
}

main "$@"
