local M = {}

-- Execute a git command and return the output
function M.exec(cmd, opts)
  opts = opts or {}

  -- Add "git" to the beginning of the command if not already present
  if not vim.startswith(cmd, "git ") then
    cmd = "git " .. cmd
  end

  -- Execute the command
  local output = vim.fn.system(cmd)

  -- Check for errors
  if vim.v.shell_error ~= 0 and not opts.ignore_errors then
    error("Git command failed: " .. output)
  end

  return output
end

-- Get the current diff
function M.get_diff()
  -- Check if there are staged changes
  local staged_diff = M.exec("diff --staged", { ignore_errors = true })

  if staged_diff and #staged_diff > 0 then
    return staged_diff
  end

  -- If no staged changes, get the working tree diff
  local working_diff = M.exec("diff", { ignore_errors = true })

  if working_diff and #working_diff > 0 then
    return working_diff
  end

  return nil
end

-- Get the diff between current branch and main/master
function M.get_branch_diff()
  -- Try to determine the main branch (main or master)
  local main_branch = "main"
  local has_main = vim.fn.system("git rev-parse --verify origin/main 2>/dev/null; echo $?"):match("^0$")

  if not has_main then
    main_branch = "master"
  end

  -- Get the diff between current branch and main branch
  local diff = M.exec("diff origin/" .. main_branch .. "...HEAD", { ignore_errors = true })

  if diff and #diff > 0 then
    return diff
  end

  return nil
end

-- Get recent commit messages
function M.get_recent_commits()
  -- Try to determine the main branch (main or master)
  local main_branch = "main"
  local has_main = vim.fn.system("git rev-parse --verify origin/main 2>/dev/null; echo $?"):match("^0$")

  if not has_main then
    main_branch = "master"
  end

  -- Get commit messages since diverging from main
  local commits = M.exec("log --oneline origin/" .. main_branch .. "..HEAD", { ignore_errors = true })

  if commits and #commits > 0 then
    return commits
  end

  return nil
end

-- Get PR template content
function M.get_pr_template(custom_path)
  local template_path = custom_path or require("hum").config.pr_template_path

  -- Try to read the PR template
  local root_dir = M.exec("rev-parse --show-toplevel"):gsub("%s+$", "")
  local full_path = root_dir .. "/" .. template_path

  local ok, content = pcall(function()
    local file = io.open(full_path, "r")
    if not file then
      return nil
    end

    local content = file:read("*all")
    file:close()
    return content
  end)

  if ok and content then
    return content
  end

  -- Fallback template
  return [[
## Description

<!-- Describe the changes you've made -->

## Related Issues

<!-- Link any related issues here -->

## Testing

<!-- Describe how you tested these changes -->
  ]]
end

return M