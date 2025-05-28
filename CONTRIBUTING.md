# Contributing to Hum

Thank you for your interest in contributing to Hum!

## Development Setup

1. Clone the repository
2. Set up your development environment:
   ```bash
   # Install Lua using asdf
   asdf plugin add lua
   asdf install lua 5.4.7
   asdf set lua 5.4.7
   
   # Set up the project (installs git hooks and dependencies)
   make setup
   
   # Alternatively, install dependencies separately
   make deps  # Installs luacheck, busted, luacov, etc.
   ```
3. Set up your API key environment variable:
   ```bash
   export CLAUDE_API_KEY=your_api_key_here
   ```
4. Open the project in Neovim
5. Source the plugin for testing:
   ```vim
   :lua package.loaded['hum'] = nil
   :lua package.loaded['hum.claude'] = nil
   :lua package.loaded['hum.git'] = nil
   :lua package.loaded['hum.prompts'] = nil
   :lua require('hum').setup()
   ```

## Linting

The project uses `luacheck` for linting Lua files:

```bash
# Run linting manually
make lint

# Run linting script to fix common issues
lua scripts/fix-lint.lua
```

A pre-commit Git hook is installed with `make setup` to run linting automatically before each commit.

## Testing

You can test the plugin commands after setting up:

```vim
:HumCommit
:HumPR
```

## Pull Requests

1. Fork the repository
2. Create a new branch
3. Make your changes
4. Submit a pull request

## Code Style

- Follow Lua best practices
- Use 2 spaces for indentation
- Add comments for complex logic