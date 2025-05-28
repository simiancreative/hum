require("spec.helpers.setup")
local mocks = require("spec.helpers.mocks")

describe("hum", function()
  local restore_vim
  local restore_os
  local hum
  
  before_each(function()
    restore_vim = mocks.mock_vim()
    restore_os = mocks.mock_os()
    
    -- Clear package cache to ensure fresh module
    package.loaded["hum"] = nil
    package.loaded["hum.claude"] = nil
    package.loaded["hum.git"] = nil
    package.loaded["hum.prompts"] = nil
    
    -- Load the module
    hum = require("hum")
  end)
  
  after_each(function()
    restore_vim()
    restore_os()
  end)
  
  describe("setup", function()
    it("should set default config values", function()
      hum.setup()
      
      assert.is_nil(hum.config.claude_api_key)
      assert.equals("claude-3-sonnet-20240229", hum.config.model)
      assert.equals(".github/PULL_REQUEST_TEMPLATE.md", hum.config.pr_template_path)
    end)
    
    it("should merge custom config values", function()
      hum.setup({
        claude_api_key = "custom-api-key",
        model = "custom-model",
      })
      
      assert.equals("custom-api-key", hum.config.claude_api_key)
      assert.equals("custom-model", hum.config.model)
      assert.equals(".github/PULL_REQUEST_TEMPLATE.md", hum.config.pr_template_path)
    end)
  end)
  
  describe("get_api_key", function()
    it("should get API key from config", function()
      hum.setup({
        claude_api_key = "config-api-key",
      })
      
      assert.equals("config-api-key", hum.get_api_key())
    end)
    
    it("should fall back to environment variable", function()
      hum.setup()
      
      assert.equals("mock-api-key", hum.get_api_key())
    end)
  end)
  
  describe("create_commands", function()
    it("should register Neovim commands", function()
      -- Setup spy on nvim_create_user_command
      local create_command_spy = spy.on(vim.api, "nvim_create_user_command")
      
      hum.create_commands()
      
      assert.spy(create_command_spy).was_called(2)
      assert.spy(create_command_spy).was_called_with("HumCommit", match.is_function(), {})
      assert.spy(create_command_spy).was_called_with("HumPR", match.is_function(), {})
    end)
  end)
end)