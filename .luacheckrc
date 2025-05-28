-- Lua linting configuration
-- See: https://github.com/mpeterv/luacheck

-- Global objects defined by Neovim that luacheck doesn't know about
globals = {
  "vim",
}

-- Don't report unused self arguments of methods
self = false

-- Rerun tests only if their modification time changed
cache = true

-- Check code in strict mode
std = "luajit+busted"

-- Allow module-pattern globals
files["lua/**/init.lua"] = {
  allow_defined_top = true,
}

-- Exclude third-party modules
exclude_files = {
  "lua/plenary/**",
}

-- Additional options
max_line_length = 120