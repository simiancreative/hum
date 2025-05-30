local M = {}

-- Claude API pricing (per million tokens)
local PRICING = {
  ["claude-3-sonnet-20240229"] = { input = 3.00, output = 15.00 },
  ["claude-3-haiku-20240307"] = { input = 0.25, output = 1.25 },
  ["claude-3-opus-20240229"] = { input = 15.00, output = 75.00 },
  ["claude-3-5-sonnet-20240620"] = { input = 3.00, output = 15.00 },
  ["claude-3-5-haiku-20241022"] = { input = 1.00, output = 5.00 }
}

-- Calculate cost based on model and token usage
function M.calculate_cost(model, input_tokens, output_tokens)
  local pricing = PRICING[model]
  if not pricing then
    return 0
  end

  local input_cost = (input_tokens * pricing.input) / 1000000
  local output_cost = (output_tokens * pricing.output) / 1000000

  return input_cost + output_cost
end

-- Extract usage metrics from Claude API response
function M.extract_usage_from_response(response)
  local model = response.model or "unknown"
  local usage = response.usage or {}

  local input_tokens = usage.input_tokens or 0
  local output_tokens = usage.output_tokens or 0
  local cost = M.calculate_cost(model, input_tokens, output_tokens)

  return {
    model = model,
    input_tokens = input_tokens,
    output_tokens = output_tokens,
    cost = cost
  }
end

-- Format metrics for display
function M.format_metrics(metrics)
  local model_short = metrics.model:gsub("^claude%-", ""):gsub("%-20%d+", "")

  -- Format cost with appropriate precision
  local cost_str
  if metrics.cost >= 0.01 then
    cost_str = string.format("$%.2f", metrics.cost)
  elseif metrics.cost >= 0.001 then
    cost_str = string.format("$%.3f", metrics.cost)
  else
    cost_str = "$0.00"
  end

  return string.format(
    "Model: %s | Tokens: %d in / %d out | Cost: %s",
    model_short,
    metrics.input_tokens,
    metrics.output_tokens,
    cost_str
  )
end

-- Display metrics as vim notification
function M.display_metrics(metrics, config)
  config = config or {}

  if config.show_metrics == false then
    return
  end

  local formatted = M.format_metrics(metrics)
  vim.notify(formatted, vim.log.levels.INFO)
end

return M