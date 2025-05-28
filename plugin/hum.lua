-- Entry point for the hum plugin
-- This file allows the plugin to be loaded automatically by Neovim

-- This ensures the plugin is only loaded once
if vim.g.loaded_hum then
  return
end
vim.g.loaded_hum = true