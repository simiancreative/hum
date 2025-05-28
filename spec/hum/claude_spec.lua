require("spec.helpers.setup")
local mocks = require("spec.helpers.mocks")

describe("hum.claude", function()
  local restore_vim
  local restore_os
  local hum
  local claude
  
  before_each(function()
    restore_vim = mocks.mock_vim()
    restore_os = mocks.mock_os()
    
    -- Clear package cache to ensure fresh module
    package.loaded["hum"] = nil
    package.loaded["hum.claude"] = nil
    
    -- Load the modules
    hum = require("hum")
    hum.setup({ claude_api_key = "test-api-key" })
    claude = require("hum.claude")
  end)
  
  after_each(function()
    restore_vim()
    restore_os()
  end)
  
  describe("build_request", function()
    it("should build a valid Claude API request", function()
      local cmd = claude.build_request("Test prompt")
      
      -- Verify the command is a table
      assert.is_table(cmd)
      
      -- Verify curl is the first element
      assert.equals("curl", cmd[1])
      
      -- Verify API key header is included
      local headers = {}
      for i, v in ipairs(cmd) do
        if v == "-H" and i < #cmd then
          table.insert(headers, cmd[i+1])
        end
      end
      
      local has_api_key = false
      for _, header in ipairs(headers) do
        if header:match("^x%-api%-key: ") then
          has_api_key = true
          break
        end
      end
      
      assert.is_true(has_api_key)
    end)
    
    pending("should error when API key is missing - pending due to test environment constraints")
  end)
  
  describe("format_response", function()
    it("should trim whitespace from response", function()
      local formatted = claude.format_response("  Test response  ")
      assert.equals("Test response", formatted)
    end)
    
    it("should remove markdown code blocks", function()
      local response = [[```
This is a code block
```]]
      local formatted = claude.format_response(response)
      assert.equals("This is a code block", formatted:gsub("\n$", ""))
    end)
    
    it("should return empty string for nil input", function()
      local formatted = claude.format_response(nil)
      assert.equals("", formatted)
    end)
  end)
end)