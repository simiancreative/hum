local M = {}

-- Default configuration
M.config = {
  claude_api_key = nil,  -- API key for Claude
  model = "claude-3-sonnet-20240229",  -- Default model to use
  pr_template_path = ".github/PULL_REQUEST_TEMPLATE.md",  -- Default PR template path
}

-- Lazily load modules to avoid circular dependencies
local function require_module(name)
  return function()
    return require("hum." .. name)
  end
end

local lazy = {
  claude = require_module("claude"),
  git = require_module("git"),
  prompts = require_module("prompts"),
}

-- Setup function to initialize the plugin with user configuration
function M.setup(opts)
  -- Merge user config with defaults
  if opts then
    M.config = vim.tbl_deep_extend("force", M.config, opts)
  end

  -- Register plugin commands
  M.create_commands()

  -- Validate required configuration
  M.validate_config()
end

-- Generate a commit message using Claude
local function generate_commit_message()
  local git = lazy.git()
  local claude = lazy.claude()
  local prompts = lazy.prompts()

  -- Get the diff
  local diff = git.get_diff()
  if not diff or #diff == 0 then
    vim.notify("No changes detected. Stage some changes first.", vim.log.levels.WARN)
    return
  end

  -- Notify user that we're generating the commit message
  vim.notify("Generating commit message...", vim.log.levels.INFO)

  -- Create the prompt
  local prompt = prompts.commit_prompt(diff)

  -- Send the request to Claude
  claude.send_request(prompt, function(response, err)
    if err then
      vim.notify("Error generating commit message: " .. err, vim.log.levels.ERROR)
      return
    end

    -- Format the response
    local formatted = claude.format_response(response)

    -- Open the commit editor with the generated message
    vim.cmd("Git commit")

    -- Wait for the commit buffer to be ready
    vim.defer_fn(function()
      local bufnr = vim.api.nvim_get_current_buf()
      local lines = vim.split(formatted, "\n")

      -- Set the buffer lines
      vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, lines)

      -- Move cursor to the end of the first line
      if #lines > 0 then
        vim.api.nvim_win_set_cursor(0, {1, #lines[1]})
      end
    end, 100)
  end)
end

-- Generate a PR description using Claude
local function generate_pr_description()
  local git = lazy.git()
  local claude = lazy.claude()
  local prompts = lazy.prompts()

  -- Get the PR template
  local template = git.get_pr_template()

  -- Get the diff or commit messages
  local diff = git.get_branch_diff()
  local commits = git.get_recent_commits()

  local content = diff or commits
  if not content or #content == 0 then
    vim.notify("No changes detected between this branch and main/master.", vim.log.levels.WARN)
    return
  end

  -- Notify user that we're generating the PR description
  vim.notify("Generating PR description...", vim.log.levels.INFO)

  -- Create the prompt
  local prompt = prompts.pr_prompt(template, content)

  -- Send the request to Claude
  claude.send_request(prompt, function(response, err)
    if err then
      vim.notify("Error generating PR description: " .. err, vim.log.levels.ERROR)
      return
    end

    -- Format the response
    local formatted = claude.format_response(response)

    -- Create a new scratch buffer
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(bufnr, "PR Description")

    -- Set the buffer lines
    local lines = vim.split(formatted, "\n")
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

    -- Set buffer options
    vim.api.nvim_buf_set_option(bufnr, "modifiable", true)
    vim.api.nvim_buf_set_option(bufnr, "filetype", "markdown")

    -- Switch to the buffer
    vim.api.nvim_set_current_buf(bufnr)

    -- Notify user
    vim.notify("PR description generated!", vim.log.levels.INFO)
  end)
end

-- Register Neovim commands
function M.create_commands()
  vim.api.nvim_create_user_command("HumCommit", function()
    generate_commit_message()
  end, {})

  vim.api.nvim_create_user_command("HumPR", function()
    generate_pr_description()
  end, {})
end

-- Get the Claude API key from config or environment
function M.get_api_key()
  return M.config.claude_api_key or os.getenv("CLAUDE_API_KEY")
end

-- Validate required configuration
function M.validate_config()
  local api_key = M.get_api_key()

  if not api_key or api_key == "" then
    vim.notify(
      "Hum: Claude API key not found. Set via hum.setup({claude_api_key = ...}) or CLAUDE_API_KEY env var.",
      vim.log.levels.WARN
    )
  end
end

return M