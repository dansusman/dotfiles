# Utility Scripts

This directory contains various utility scripts for development and system automation.

## Scripts

### Development & Git

- **`generate-commit`** - Generate conventional commit messages using Claude CLI
- **`git-bare-clone`** - Clone git repositories in bare mode
- **`git-create-worktree`** - Create new git worktrees
- **`git-rebase`** - Interactive git rebase helper
- **`git-update`** - Update git repositories
- **`gwt`** - Git worktree utilities
- **`ntb_new_worktree`** - Create new worktree branches
- **`wt`** - Fast git worktree switcher

### Claude Code Integration

- **`claude-notify`** - macOS notification for Claude Code user input
- **`claude-start`** - Start Claude Code services
- **`claude-stop`** - Stop Claude Code services
- **`install-claude-commit`** - Install Claude commit message generator

### System Utilities

- **`airdrop`** - Open AirDrop
- **`audio-switch`** - Switch audio output devices
- **`togglewifi`** - Toggle WiFi on/off with mock mode for testing
- **`kth`** - Convert key names to ASCII hex codes for Ghostty keybinds
- **`ui`** - Get iOS Simulator app storage paths

### Project Management

- **`tm`** - Tmux session manager with interactive selection
- **`open-issue`** - Open GitHub issues from command line
- **`generate-slack-msg`** - Generate Slack messages
- **`sfl`** - Project-specific utilities

### Misc

- **`bin`** - Binary utilities
- **`contrib`** - Contribution scripts

## Usage

All scripts are executable and can be run directly from the command line. Most scripts include help options (`-h` or `--help`) for detailed usage information.

Scripts are typically added to PATH via the dotfiles installation process.