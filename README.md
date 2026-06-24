# dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Apply on a new machine

```sh
chezmoi init --apply <this-repo-url>
```

You will be prompted for your name and email. The email determines
machine-specific behavior (see below).

On Arch Linux, `chezmoi apply` automatically runs
`.chezmoiscripts/run_onchange_install-packages.sh`, which lists the packages it
is about to install and then installs any that are missing via
`sudo pacman -S --needed`. On non-Arch systems the script does nothing except
print the package list to install manually.

## Dependencies

### Required to apply the dotfiles

| Package | Provides | Why |
| --- | --- | --- |
| `chezmoi` | `chezmoi` | applies the dotfiles |
| `git` | `git` | chezmoi source control |
| `git-delta` | `delta` | `chezmoi diff` (config sets `diff-command = "delta"`) |

### Shell / terminal

| Package | Provides | Why |
| --- | --- | --- |
| `zsh` | `zsh` | `~/.zshrc` |
| `tmux` | `tmux` | `~/.tmux.conf` |

### Neovim (full functionality)

| Package | Provides | Why |
| --- | --- | --- |
| `neovim` | `nvim` | the editor (>= 0.10) |
| `gcc`, `make` | C compiler | nvim-treesitter parser compilation |
| `ripgrep` | `rg` | Telescope live grep |
| `fd` | `fd` | Telescope file finding (optional but recommended) |
| `unzip`, `curl` | `unzip`, `curl` | mason.nvim downloads LSP servers |
| `nodejs`, `npm` | `node`, `npm` | mason LSP servers (e.g. bash-language-server) |
| `python`, `python-pip` | `python`, `pip` | pylsp, and `c_formatter_42` on 42 machines |

### Not required

`luarocks` / `lua` are **not** needed: luarocks support is disabled in
`lazy.nvim` (`rocks = { enabled = false }`), so plugins that ship a rockspec
(telescope, plenary) install as pure Lua without hererocks.

### Arch install command

```sh
sudo pacman -S --needed git curl zsh tmux neovim gcc make ripgrep fd unzip nodejs npm python python-pip git-delta
```

## Machine-specific behavior

Behavior is selected from the email entered during `chezmoi init`. A work email
(`@rockwellautomation.com`) is treated as the work machine.

| Setting | Work | Personal / 42 |
| --- | --- | --- |
| `c_formatter_42`, `42header` nvim plugins | disabled | enabled |
| nvim `expandtab` | `true` | `false` |
| `mass_git` shell alias | present | absent |
