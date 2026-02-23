#!/bin/bash
# =============================================================================
# Mac Dev Bootstrap Script
# Run this on a fresh Mac to get up and running:
#   curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/dotfiles/main/bootstrap.sh | bash
# =============================================================================

set -e  # Exit on any error

# Guard against being run via curl | bash (breaks sudo on macOS)
if [ ! -t 0 ]; then
  echo ""
  echo "⚠️  Don't pipe this script — download and run it directly:"
  echo ""
  echo "  curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/dotfiles/main/bootstrap.sh -o bootstrap.sh"
  echo "  chmod +x bootstrap.sh"
  echo "  ./bootstrap.sh"
  echo ""
  exit 1
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log()    { echo -e "${BLUE}[dotfiles]${NC} $1"; }
success(){ echo -e "${GREEN}[✓]${NC} $1"; }
warn()   { echo -e "${YELLOW}[!]${NC} $1"; }
error()  { echo -e "${RED}[✗]${NC} $1"; exit 1; }

# =============================================================================
# 1. Xcode Command Line Tools
# =============================================================================
log "Checking Xcode Command Line Tools..."
if ! xcode-select -p &>/dev/null; then
  log "Installing Xcode Command Line Tools..."
  xcode-select --install
  until xcode-select -p &>/dev/null; do sleep 5; done
  success "Xcode Command Line Tools installed"
else
  success "Xcode Command Line Tools already installed"
fi

# =============================================================================
# 2. Homebrew
# =============================================================================
log "Checking Homebrew..."
if ! command -v brew &>/dev/null; then
  log "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ $(uname -m) == "arm64" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  success "Homebrew installed"
else
  success "Homebrew already installed"
fi

# =============================================================================
# 3. chezmoi — apply dotfiles
# =============================================================================
log "Checking chezmoi..."
if ! command -v chezmoi &>/dev/null; then
  log "Installing chezmoi..."
  brew install chezmoi
  success "chezmoi installed"
else
  success "chezmoi already installed"
fi

DOTFILES_REPO="https://github.com/YOUR_USERNAME/dotfiles"
log "Applying dotfiles from $DOTFILES_REPO..."
chezmoi init --apply "$DOTFILES_REPO"
success "Dotfiles applied"

# =============================================================================
# 4. Homebrew Bundle — install everything in Brewfile
# =============================================================================
log "Installing packages from Brewfile..."
brew bundle --file="$(chezmoi source-path)/Brewfile"
success "Homebrew packages installed"

# =============================================================================
# 5. Oh My Zsh
# =============================================================================
log "Checking Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  log "Installing Oh My Zsh..."
  RUNZSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  success "Oh My Zsh installed"
else
  success "Oh My Zsh already installed"
fi

# =============================================================================
# 6. Set zsh as default shell
# =============================================================================
if [ "$SHELL" != "$(which zsh)" ]; then
  log "Setting zsh as default shell..."
  chsh -s "$(which zsh)"
  success "Default shell set to zsh"
else
  success "zsh is already the default shell"
fi

# =============================================================================
# 7. VS Code — install 'code' CLI command
# =============================================================================
log "Checking VS Code..."
if ! command -v code &>/dev/null; then
  if [ -d "/Applications/Visual Studio Code.app" ]; then
    # App exists (installed via Brewfile) but CLI not in PATH yet — install it
    ln -sf "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" \
      /usr/local/bin/code
    success "VS Code CLI (code) linked"
  else
    warn "VS Code not found — installing via Homebrew cask..."
    brew install --cask visual-studio-code
    success "VS Code installed"
  fi
else
  success "VS Code already installed: $(code --version | head -1)"
fi

# =============================================================================
# 8. mise — language version manager
# =============================================================================
log "Setting up mise..."
eval "$(mise activate bash)"
# No runtimes installed by default — install what you need:
#   mise use --global node@lts
#   mise use --global python@latest
#   mise use --global go@latest
success "mise ready — run 'mise use --global <runtime>@<version>' to install languages"

# =============================================================================
# Done!
# =============================================================================
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  Bootstrap complete! Restart your terminal.${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo "Next steps:"
echo "  1. Open Warp terminal"
echo "  2. Add secrets: echo 'export ANTHROPIC_API_KEY=\"sk-ant-...\"' >> ~/.zshenv.local"
echo "  3. Install language runtimes: mise use --global node@lts"
echo "  4. Run 'chezmoi edit' to customize your dotfiles"
