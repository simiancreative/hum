-- Mock Neovim functionality for tests
local M = {}

-- Create mock vim global
function M.mock_vim()
  -- Store original vim if it exists
  local original_vim = _G.vim
  
  -- Create mock vim
  _G.vim = {
    g = {},
    b = {},
    o = {},
    fn = {
      system = function(cmd) return "" end,
      jobstart = function(cmd, opts) return 1 end,
    },
    api = {
      nvim_create_user_command = function(name, fn, opts) end,
      nvim_create_buf = function(listed, scratch) return 1 end,
      nvim_buf_set_lines = function(bufnr, start, end_, strict, lines) end,
      nvim_buf_set_name = function(bufnr, name) end,
      nvim_buf_set_option = function(bufnr, name, value) end,
      nvim_set_current_buf = function(bufnr) end,
      nvim_win_set_cursor = function(win, pos) end,
      nvim_get_current_buf = function() return 1 end,
    },
    cmd = function(str) end,
    defer_fn = function(fn, timeout) fn() end,
    notify = function(msg, level) end,
    log = {
      levels = {
        INFO = 2,
        WARN = 3,
        ERROR = 4,
      }
    },
    split = function(str, sep) return {} end,
    startswith = function(str, prefix) return string.sub(str, 1, #prefix) == prefix end,
    tbl_deep_extend = function(behavior, ...) 
      local result = {}
      for i = 1, select("#", ...) do
        local tbl = select(i, ...)
        for k, v in pairs(tbl) do
          result[k] = v
        end
      end
      return result
    end,
    json = {
      encode = function(obj) return "{}" end,
      decode = function(str) return {} end,
    },
    v = {
      shell_error = 0,
    },
  }
  
  return function()
    -- Restore original vim
    if original_vim then
      _G.vim = original_vim
    else
      _G.vim = nil
    end
  end
end

-- Mock os functionality
function M.mock_os()
  -- Store original os.getenv
  local original_getenv = os.getenv
  
  -- Override os.getenv
  os.getenv = function(name)
    if name == "CLAUDE_API_KEY" then
      return "mock-api-key"
    end
    return original_getenv(name)
  end
  
  return function()
    -- Restore original os.getenv
    os.getenv = original_getenv
  end
end

return M