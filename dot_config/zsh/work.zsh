#!/usr/bin/env zsh
# Work-only WSL helpers. Managed by chezmoi; only materialised on the Rockwell
# work machine (see .chezmoiignore gate on .email). Sourced from ~/.zshrc.

export WIN_HOME="/mnt/c/Users/DPrikhodko"
export WIN_PROJECTS="$WIN_HOME/Projects"

win_home() { cd "$WIN_HOME"; }
projects() { cd "$WIN_PROJECTS"; }

cmake() {
  local exe="/mnt/c/Program Files/CMake/bin/cmake.exe"
  local -a out=()
  local a
  for a in "$@"; do
    if [[ "$a" == /mnt/* ]]; then
      out+=("$(wslpath -m "$a")")
    elif [[ "$a" == *=/mnt/* ]]; then
      out+=("${a%%=*}=$(wslpath -m "${a#*=}")")
    else
      out+=("$a")
    fi
  done
  "$exe" "${out[@]}"
}
