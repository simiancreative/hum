require("spec.helpers.setup")

describe("hum.metrics", function()
  local metrics
  
  before_each(function()
    -- Clear package cache to ensure fresh module
    package.loaded["hum.metrics"] = nil
    
    -- Load the module
    metrics = require("hum.metrics")
  end)
  
  describe("calculate_cost", function()
    it("should calculate cost for claude-3-sonnet", function()
      local cost = metrics.calculate_cost("claude-3-sonnet-20240229", 1000, 500)
      
      -- Claude 3 Sonnet: $3/MTok input, $15/MTok output
      local expected = (1000 * 3 + 500 * 15) / 1000000
      assert.is_near(expected, cost, 0.000001)
    end)
    
    it("should calculate cost for claude-3-haiku", function()
      local cost = metrics.calculate_cost("claude-3-haiku-20240307", 1000, 500)
      
      -- Claude 3 Haiku: $0.25/MTok input, $1.25/MTok output
      local expected = (1000 * 0.25 + 500 * 1.25) / 1000000
      assert.equals(expected, cost)
    end)
    
    it("should return 0 for unknown model", function()
      local cost = metrics.calculate_cost("unknown-model", 1000, 500)
      assert.equals(0, cost)
    end)
  end)
  
  describe("format_metrics", function()
    it("should format metrics with cost in cents", function()
      local formatted = metrics.format_metrics({
        model = "claude-3-sonnet-20240229",
        input_tokens = 1000,
        output_tokens = 500,
        cost = 0.0105
      })
      
      assert.matches("Model: 3%-sonnet", formatted)
      assert.matches("Tokens: 1000 in / 500 out", formatted)
      assert.matches("Cost: %$0%.01", formatted)
    end)
    
    it("should format metrics with cost in dollars", function()
      local formatted = metrics.format_metrics({
        model = "claude-3-sonnet-20240229",
        input_tokens = 10000,
        output_tokens = 5000,
        cost = 0.105
      })
      
      assert.matches("Cost: %$0%.10", formatted)
    end)
    
    it("should handle very small costs", function()
      local formatted = metrics.format_metrics({
        model = "claude-3-haiku-20240307",
        input_tokens = 100,
        output_tokens = 50,
        cost = 0.0000875
      })
      
      assert.matches("Cost: %$0%.00", formatted)
    end)
  end)
  
  describe("extract_usage_from_response", function()
    it("should extract usage from Claude API response", function()
      local response = {
        model = "claude-3-sonnet-20240229",
        usage = {
          input_tokens = 1500,
          output_tokens = 750
        }
      }
      
      local usage = metrics.extract_usage_from_response(response)
      
      assert.equals("claude-3-sonnet-20240229", usage.model)
      assert.equals(1500, usage.input_tokens)
      assert.equals(750, usage.output_tokens)
      assert.is_number(usage.cost)
    end)
    
    it("should handle missing usage data", function()
      local response = {
        model = "claude-3-sonnet-20240229"
      }
      
      local usage = metrics.extract_usage_from_response(response)
      
      assert.equals("claude-3-sonnet-20240229", usage.model)
      assert.equals(0, usage.input_tokens)
      assert.equals(0, usage.output_tokens)
      assert.equals(0, usage.cost)
    end)
    
    it("should handle missing model", function()
      local response = {
        usage = {
          input_tokens = 1500,
          output_tokens = 750
        }
      }
      
      local usage = metrics.extract_usage_from_response(response)
      
      assert.equals("unknown", usage.model)
      assert.equals(1500, usage.input_tokens)
      assert.equals(750, usage.output_tokens)
    end)
  end)
end)