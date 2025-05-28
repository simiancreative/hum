#!/usr/bin/env lua

-- Script to fix common linting issues
-- Usage: lua scripts/fix-lint.lua

local function process_file(file_path)
  print("Processing " .. file_path)
  
  -- Read the file
  local file = io.open(file_path, "r")
  if not file then
    print("Error: Could not open file " .. file_path)
    return
  end
  
  local content = file:read("*all")
  file:close()
  
  -- Remove trailing whitespace and empty lines
  content = content:gsub(" +\n", "\n")
  content = content:gsub("\n\n+", "\n\n")
  
  -- Write the file
  file = io.open(file_path, "w")
  if not file then
    print("Error: Could not write to file " .. file_path)
    return
  end
  
  file:write(content)
  file:close()
  
  print("Fixed " .. file_path)
end

-- Process all Lua files
local files = {
  "lua/hum/init.lua",
  "lua/hum/claude.lua",
  "lua/hum/git.lua",
  "lua/hum/prompts.lua"
}

for _, file in ipairs(files) do
  process_file(file)
end

print("Done!")