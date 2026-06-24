#!/usr/bin/env bash
set -euo pipefail

PACKAGES=(
	git
	curl
	zsh
	tmux
	less
	gcc
	make
	tree-sitter-cli
	ripgrep
	fd
	unzip
	nodejs
	npm
	python
	python-pip
	git-delta
)

if [ ! -r /etc/os-release ]; then
	echo "install-packages: cannot read /etc/os-release; skipping."
	exit 0
fi

. /etc/os-release

if [ "${ID:-}" != "arch" ]; then
	echo "install-packages: detected '${ID:-unknown}', not Arch Linux; skipping automatic package installation."
	echo "install-packages: install these manually for full functionality: ${PACKAGES[*]}"
	exit 0
fi

if ! command -v pacman >/dev/null 2>&1; then
	echo "install-packages: pacman not found; skipping."
	exit 0
fi

echo "install-packages: Arch Linux detected."
echo "install-packages: the following packages will be installed (already-present ones are skipped):"
printf '  - %s\n' "${PACKAGES[@]}"

sudo pacman -S --needed "${PACKAGES[@]}"
