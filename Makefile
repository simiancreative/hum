.PHONY: lint lint-fix hooks setup test test-coverage deps

# Install dependencies
deps:
	@echo "Installing development dependencies..."
	@command -v luarocks >/dev/null 2>&1 || { echo >&2 "luarocks not found. Please install Lua and LuaRocks first."; exit 1; }
	@echo "Installing luacheck..."
	@luarocks install luacheck
	@echo "Installing busted testing framework..."
	@luarocks install busted
	@echo "Installing luacov for code coverage..."
	@luarocks install luacov
	@luarocks install luacov-reporter-lcov
	@echo "Dependencies installed successfully."
	@asdf reshim lua 2>/dev/null || true

# Run luacheck for linting
lint:
	@echo "Running luacheck..."
	@command -v luacheck >/dev/null 2>&1 || { echo >&2 "luacheck not found. Install with 'make deps'"; exit 1; }
	@luacheck lua/

# Run stylua for formatting if available
lint-fix:
	@echo "Running stylua (if available)..."
	@if command -v stylua >/dev/null 2>&1; then \
		stylua lua/; \
	else \
		echo "stylua not found. Install with 'cargo install stylua'"; \
	fi

# Install git hooks
hooks:
	@echo "Installing git hooks..."
	@mkdir -p .git/hooks
	@cp -f scripts/pre-commit .git/hooks/pre-commit
	@chmod +x .git/hooks/pre-commit
	@echo "Git hooks installed successfully"

# Run tests
test:
	@echo "Running tests..."
	@command -v busted >/dev/null 2>&1 || { echo >&2 "busted not found. Install with 'make deps'"; exit 1; }
	@./scripts/run-tests.sh -v

# Run tests with coverage
test-coverage:
	@echo "Running tests with coverage..."
	@command -v busted >/dev/null 2>&1 || { echo >&2 "busted not found. Install with 'make deps'"; exit 1; }
	@command -v luacov >/dev/null 2>&1 || { echo >&2 "luacov not found. Install with 'make deps'"; exit 1; }
	@./scripts/run-tests.sh -c && luacov

# Setup development environment
setup: hooks deps
	@echo "Setting up development environment..."
	@echo "Setup complete"
