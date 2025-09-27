#!/usr/bin/env bash
set -Eeuo pipefail
trap 'echo "$0: line $LINENO: $BASH_COMMAND: exitcode $?"' ERR

if [[ $OSTYPE != 'darwin'* ]]; then
    echo >&2 "ERROR: this script is for Mac OSX"
    exit 1
fi

##############
# Create SSH key
##############
if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
    mkdir -p "$HOME/.ssh"
    ssh-keygen -t ed25519 -f "$HOME/.ssh/id_ed25519" -N '' </dev/null
fi


##############
# All Applications
##############
# Expand save dialog by default
defaults write -g NSNavPanelExpandedStateForSaveMode -bool true

# Save to disk (not to iCloud) by default
defaults write -g NSDocumentSaveNewDocumentsToCloud -bool false


##############
# Keyboard
##############
# Set fast keyboard repeat rate
defaults write -g KeyRepeat -int 2
defaults write -g InitialKeyRepeat -int 12

# enable keyboard navigation to move focus between controls (tab / shift-tab)
defaults write -g AppleKeyboardUIMode -int 3

# default behavior when holding down a key is to bring up a menu of characters with different diacritical marks.
# Try holding down ‘e’ to see this in action. If you want to instead repeat characters when a key is held:
defaults write -g ApplePressAndHoldEnabled -bool false

# disable Cmd-M as minimize window by assigning it to "Center"
defaults write -g NSUserKeyEquivalents -dict-add "Center" "@m"


##############
# Finder
##############
# Finder: show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Finder: show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Allow quitting Finder
defaults write com.apple.finder QuitMenuItem -bool true

# Set new window location to $HOME directory
defaults write com.apple.finder NewWindowTarget -string "PfHm"

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

##############
# Misc
##############
# Hide the dock
defaults write com.apple.dock autohide -bool true && killall Dock &>/dev/null || true

# Disable crash reporting
defaults write com.apple.CrashReporter DialogType none

##############
# Install brew
##############
if ! command -v brew &> /dev/null ; then
    /usr/bin/env bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    brew update --quiet && brew upgrade --quiet
fi

##############
# Install applications
##############
BrewApps=()
BrewApps+=(atuin)               # better shell history
BrewApps+=(bash)                # replace OSX bash 3.2 with something modern
BrewApps+=(bat)                 # better cat
BrewApps+=(coreutils)           # replace old BSD command-line tools with GNU
BrewApps+=(direnv)              # per-directory environment
BrewApps+=(eza)                 # better ls
BrewApps+=(fd)                  # better than unix `find`
BrewApps+=(findutils)           # includes gxargs with the '-r' option
BrewApps+=(fzf)                 # fuzzy file-finder
BrewApps+=(gh)                  # github command-line
BrewApps+=(git)                 # yeah, it's the best
BrewApps+=(git-delta)           # better pager for git diff
BrewApps+=(git-lfs)             # big files
BrewApps+=(gnu-getopt)          # because OSX getopt is ancient
BrewApps+=(jless)               # JSON viewer
BrewApps+=(jq)                  # mangle JSON from the command line
BrewApps+=(jql)                 # JSON query language
BrewApps+=(mas)                 # Apple Store command line
BrewApps+=(moreutils)           # ifne/chronic/ts/sponge/vipe/pee
BrewApps+=(netcat)              # play with sockets
BrewApps+=(procs)               # process list (replaces ps)
BrewApps+=(python)              # Python language
BrewApps+=(rg)                  # better grep
BrewApps+=(sd)                  # better sed
BrewApps+=(shellcheck)          # lint for bash
BrewApps+=(starship)            # console prompt
BrewApps+=(tig)                 # graphical git commit viewer
BrewApps+=(tmux)                # terminal multiplexer
BrewApps+=(uv)                  # python package manager
BrewApps+=(wget)                # curl with different defaults
BrewApps+=(zoxide)              # directory jumper (replaces z.sh)
brew install --quiet "${BrewApps[@]}"

CaskApps=()
CaskApps+=(ghostty)             # terminal by Mitchell Hashimoto that rocks
CaskApps+=(google-chrome)       # spyware-riddled web browser
CaskApps+=(rectangle)           # hotkeys to position windows
CaskApps+=(scroll-reverser)     # reverse mouse wheel scrolling
CaskApps+=(sublime-text)        # better text editor
CaskApps+=(swift-quit)          # quit apps with no documents
CaskApps+=(visual-studio-code)  # development environment
brew install --quiet --cask "${CaskApps[@]}"


##############
# Install xcode
##############
xcode-select -p &>/dev/null || xcode-select --install
mas install 497799835

# Set Xcode so that it writes derived data into the project directory.
# It's unfortunate that this has to be set globally, but other methods didn't work
defaults write com.apple.dt.Xcode DerivedDataLocationStyle Custom
defaults write com.apple.dt.Xcode IDECustomDerivedDataLocation ".DerivedData"
