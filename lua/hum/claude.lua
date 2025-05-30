local M = {}
local hum = require("hum")

-- Base URL for Claude API
local API_URL = "https://api.anthropic.com/v1/messages"

-- Build a Claude API request with the given prompt
function M.build_request(prompt, opts)
  opts = opts or {}

  local api_key = hum.get_api_key()
  if not api_key or api_key == "" then
    error("Claude API key not found")
  end

  local model = opts.model or hum.config.model

  -- Build the request body
  local body = vim.json.encode({
    model = model,
    max_tokens = opts.max_tokens or 1024,
    messages = {
      {
        role = "user",
        content = prompt
      }
    }
  })

  -- Build the curl command
  local cmd = {
    "curl",
    "-s",
    API_URL,
    "-H", "Content-Type: application/json",
    "-H", "x-api-key: " .. api_key,
    "-H", "anthropic-version: 2023-06-01",
    "-d", body
  }

  return cmd
end

-- Send a request to the Claude API
function M.send_request(prompt, callback, opts)
  local cmd = M.build_request(prompt, opts)

  -- Use vim.fn.jobstart to make an async request
  local stdout_data = ""
  local stderr_data = ""

  local job_id = vim.fn.jobstart(cmd, {
    on_stdout = function(_, data, _)
      if data then
        for _, line in ipairs(data) do
          if line and line ~= "" then
            stdout_data = stdout_data .. line .. "\n"
          end
        end
      end
    end,
    on_stderr = function(_, data, _)
      if data then
        for _, line in ipairs(data) do
          if line and line ~= "" then
            stderr_data = stderr_data .. line .. "\n"
          end
        end
      end
    end,
    on_exit = function(_, exit_code, _)
      if exit_code ~= 0 then
        callback(nil, stderr_data)
        return
      end

      -- Parse the JSON response
      local ok, response = pcall(vim.json.decode, stdout_data)
      if not ok then
        callback(nil, "Failed to parse Claude API response: " .. stdout_data)
        return
      end

      -- Extract the content from the response
      if response.content and #response.content > 0 then
        local text = ""
        for _, content_part in ipairs(response.content) do
          if content_part.type == "text" then
            text = text .. content_part.text
          end
        end
        callback(text, nil, response)
      else
        callback(nil, "Unexpected response format: " .. vim.inspect(response))
      end
    end
  })

  if job_id <= 0 then
    callback(nil, "Failed to start job")
  end

  return job_id
end

-- Format Claude's response
function M.format_response(text)
  if not text then return "" end

  -- Trim whitespace
  text = text:gsub("^%s+", ""):gsub("%s+$", "")

  -- Remove markdown block quotes if present
  text = text:gsub("```[%w]*\n", ""):gsub("```$", "")

  -- Remove any explanatory text or notes at the beginning
  text = text:gsub("^Note:.-\n\n", "")
  text = text:gsub("^Here's a commit message:.-\n\n", "")
  text = text:gsub("^Commit message:.-\n\n", "")
  text = text:gsub("^I've generated the following.-\n\n", "")
  text = text:gsub("^Based on the diff.-\n\n", "")

  -- Remove any explanatory text at the end
  text = text:gsub("\n\nLet me know if you.-$", "")
  text = text:gsub("\n\nIs there anything else.-$", "")
  text = text:gsub("\n\nThis commit message.-$", "")

  return text
end

return M