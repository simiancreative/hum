require("spec.helpers.setup")
local mocks = require("spec.helpers.mocks")

describe("motivation integration", function()
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
    hum.setup({ claude_api_key = "test-key" })
  end)
  
  after_each(function()
    restore_vim()
    restore_os()
  end)
  
  describe("commit workflow with motivation", function()
    local git_spy, claude_spy, notify_spy
    
    before_each(function()
      -- Mock git
      git_spy = spy.new(function() return "mock diff content" end)
      package.loaded["hum.git"] = { get_diff = git_spy }
      
      -- Mock claude
      claude_spy = spy.new(function(prompt, callback) 
        callback("Generated commit message")
      end)
      package.loaded["hum.claude"] = { 
        send_request = claude_spy,
        format_response = function(response) return response end
      }
      
      -- Mock vim notification
      notify_spy = spy.on(vim, "notify")
    end)
    
    it("should generate commit message without motivation", function()
      hum.generate_commit()
      
      -- Verify git diff was called
      assert.spy(git_spy).was_called()
      
      -- Verify notification without motivation
      assert.spy(notify_spy).was_called_with("Generating commit message...", vim.log.levels.INFO)
      
      -- Verify claude was called with prompt containing no motivation
      assert.spy(claude_spy).was_called()
      local call_args = claude_spy.calls[1].refs
      local prompt = call_args[1]
      assert.is_string(prompt)
      assert.matches("mock diff content", prompt)
      assert.not_matches("MOTIVATION:", prompt)
    end)
    
    it("should generate commit message with motivation", function()
      hum.generate_commit("fixing critical bug")
      
      -- Verify git diff was called
      assert.spy(git_spy).was_called()
      
      -- Verify notification with motivation
      assert.spy(notify_spy).was_called_with("Generating commit message (with motivation)...", vim.log.levels.INFO)
      
      -- Verify claude was called with prompt containing motivation
      assert.spy(claude_spy).was_called()
      local call_args = claude_spy.calls[1].refs
      local prompt = call_args[1]
      assert.is_string(prompt)
      assert.matches("mock diff content", prompt)
      assert.matches("MOTIVATION:", prompt)
      assert.matches("fixing critical bug", prompt)
    end)
  end)
  
  describe("PR workflow with motivation", function()
    local git_spy, claude_spy, notify_spy
    
    before_each(function()
      -- Mock git
      git_spy = {
        get_pr_template = spy.new(function() return "PR template content" end),
        get_branch_diff = spy.new(function() return "mock diff content" end),
        get_recent_commits = spy.new(function() return "mock commits" end)
      }
      package.loaded["hum.git"] = git_spy
      
      -- Mock claude
      claude_spy = spy.new(function(prompt, callback) 
        callback("Generated PR description")
      end)
      package.loaded["hum.claude"] = { 
        send_request = claude_spy,
        format_response = function(response) return response end
      }
      
      -- Mock vim notification
      notify_spy = spy.on(vim, "notify")
    end)
    
    it("should generate PR description without motivation", function()
      hum.generate_pr()
      
      -- Verify git functions were called
      assert.spy(git_spy.get_pr_template).was_called()
      assert.spy(git_spy.get_branch_diff).was_called()
      
      -- Verify notification without motivation
      assert.spy(notify_spy).was_called_with("Generating PR description...", vim.log.levels.INFO)
      
      -- Verify claude was called with prompt containing no motivation
      assert.spy(claude_spy).was_called()
      local call_args = claude_spy.calls[1].refs
      local prompt = call_args[1]
      assert.is_string(prompt)
      assert.matches("PR template content", prompt)
      assert.matches("mock diff content", prompt)
      assert.not_matches("MOTIVATION:", prompt)
    end)
    
    it("should generate PR description with motivation", function()
      hum.generate_pr("implementing new feature")
      
      -- Verify git functions were called
      assert.spy(git_spy.get_pr_template).was_called()
      assert.spy(git_spy.get_branch_diff).was_called()
      
      -- Verify notification with motivation
      assert.spy(notify_spy).was_called_with("Generating PR description (with motivation)...", vim.log.levels.INFO)
      
      -- Verify claude was called with prompt containing motivation
      assert.spy(claude_spy).was_called()
      local call_args = claude_spy.calls[1].refs
      local prompt = call_args[1]
      assert.is_string(prompt)
      assert.matches("PR template content", prompt)
      assert.matches("mock diff content", prompt)
      assert.matches("MOTIVATION:", prompt)
      assert.matches("implementing new feature", prompt)
    end)
  end)
end)