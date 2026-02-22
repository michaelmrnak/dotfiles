# dotfiles

My Mac dev environment, managed with [chezmoi](https://www.chezmoi.io/).

## Setup

### One-time: Create the repo (do this once, from any machine or GitHub.com)

1. Create a new **public** repo called `dotfiles` on [github.com](https://github.com/new)
2. Upload all the files from this repo via the GitHub web UI (drag and drop works)
3. Update `YOUR_USERNAME` with your actual GitHub username in `bootstrap.sh` and `dot_config/chezmoi/chezmoi.toml`

### Every new Mac after that

```bash
# 1. Download and run the bootstrap script
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/dotfiles/main/bootstrap.sh -o bootstrap.sh
chmod +x bootstrap.sh
./bootstrap.sh

# 2. Restart your terminal (open Warp)

# 3. Install the language runtimes you need
mise use --global node@lts
mise use --global python@latest
mise use --global go@latest

# 4. Add your secrets
echo 'export ANTHROPIC_API_KEY="sk-ant-..."' >> ~/.zshenv.local
```

The bootstrap script handles everything else — Homebrew, chezmoi, Oh My Zsh, mise, VS Code, and cloning this repo to the right place.

---

## What Gets Installed

| Tool | Purpose |
|------|---------|
| Homebrew | Package manager |
| chezmoi | Dotfiles manager |
| git + git-delta | Version control with better diffs |
| Oh My Zsh | Shell framework |
| **mise** | **Universal version manager — Node, Python, Ruby, Go, Rust, Java, and more** |
| direnv | Per-project environment variables |
| fzf | Fuzzy finder (`Ctrl+R` for history, `Ctrl+T` for files) |
| ripgrep | Fast search (`rg`) |
| eza | Better `ls` |
| bat | Better `cat` |
| zoxide | Smarter `cd` — use `z` |
| gh | GitHub CLI |
| Warp | Terminal |
| VS Code | Editor |

---

## Managing Language Runtimes with mise

[mise](https://mise.jdx.dev) replaces language-specific version managers (`nvm`, `pyenv`, `rbenv`, `gvm`, etc.) with a single unified tool.

```bash
# Install a runtime globally
mise use --global node@lts
mise use --global python@3.12
mise use --global go@latest
mise use --global ruby@3.3

# Pin a version per project (creates .mise.toml in current dir)
cd my-project
mise use node@20
mise use python@3.11

# See everything installed
mise list

# See all available versions
mise ls-remote node
```

Per-project `.mise.toml` files can be committed to your repos so anyone with mise gets the same runtime versions automatically.

---

## Daily Dotfiles Workflow

```bash
# Edit a dotfile
chezmoi edit ~/.zshrc

# See what would change
chezmoi diff

# Apply changes to your machine
chezmoi apply

# Pull latest from GitHub and apply (on a second machine)
chezmoi update
```

With `autoCommit` and `autoPush` enabled in `chezmoi.toml`, changes are committed and pushed to GitHub automatically when you run `chezmoi apply`.

---

## Secrets Management

**Never commit real secrets to this repo.**

### Option 1: `.zshenv.local` (simple, global)
Create `~/.zshenv.local` on each machine — it's sourced by `.zshenv` but gitignored:

```bash
# ~/.zshenv.local (not in git)
export ANTHROPIC_API_KEY="sk-ant-..."
export GITHUB_TOKEN="ghp_..."
```

### Option 2: `direnv` per project (recommended for project-specific keys)
Create a `.envrc` in any project directory:

```bash
# myproject/.envrc
export ANTHROPIC_API_KEY="sk-ant-..."
export DATABASE_URL="postgres://..."
```

Then run `direnv allow` once. Vars load automatically when you `cd` in, unload when you leave.

---

## Adding a New Machine

1. Run the bootstrap script
2. Install your language runtimes via `mise use --global`
3. Add secrets to `~/.zshenv.local`

## Adding New Dotfiles

```bash
# Tell chezmoi to manage a file
chezmoi add ~/.some-new-config

# Edit it
chezmoi edit ~/.some-new-config

# Apply + auto-commit/push
chezmoi apply
```

---

## Structure

```
dotfiles/
├── bootstrap.sh          # Run on a fresh Mac
├── Brewfile              # All Homebrew packages
├── dot_zshrc             # → ~/.zshrc
├── dot_zshenv            # → ~/.zshenv
├── dot_gitconfig.tmpl    # → ~/.gitconfig (template with name/email)
├── dot_gitignore_global  # → ~/.gitignore_global
└── dot_config/
    └── chezmoi/
        └── chezmoi.toml  # chezmoi config
```

chezmoi maps filenames: `dot_` → `.`, `.tmpl` → processed as a Go template.
