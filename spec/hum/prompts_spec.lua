require("spec.helpers.setup")

describe("hum.prompts", function()
  local prompts
  
  before_each(function()
    -- Clear package cache to ensure fresh module
    package.loaded["hum.prompts"] = nil
    
    -- Load the module
    prompts = require("hum.prompts")
  end)
  
  describe("commit_prompt", function()
    it("should generate a commit prompt with diff", function()
      local diff = "test diff content"
      local prompt = prompts.commit_prompt(diff)
      
      assert.is_string(prompt)
      assert.matches("Generate a git commit message", prompt)
      assert.matches("Conventional Commits format", prompt)
      assert.matches("test diff content$", prompt) -- Diff should be at the end
    end)
    
    it("should generate a commit prompt with diff and motivation", function()
      local diff = "test diff content"
      local motivation = "fixing critical bug"
      local prompt = prompts.commit_prompt(diff, motivation)
      
      assert.is_string(prompt)
      assert.matches("Generate a git commit message", prompt)
      assert.matches("Conventional Commits format", prompt)
      assert.matches("fixing critical bug", prompt)
      assert.matches("test diff content$", prompt) -- Diff should be at the end
    end)
    
    it("should generate commit prompt without motivation when nil", function()
      local diff = "test diff content"
      local prompt = prompts.commit_prompt(diff, nil)
      
      assert.is_string(prompt)
      assert.matches("Generate a git commit message", prompt)
      assert.matches("Conventional Commits format", prompt)
      assert.matches("test diff content$", prompt) -- Diff should be at the end
    end)
  end)
  
  describe("pr_prompt", function()
    it("should generate a PR prompt with template and diff", function()
      local template = "PR template"
      local diff = "test diff content"
      local prompt = prompts.pr_prompt(template, diff)
      
      assert.is_string(prompt)
      assert.matches("Fill in the PR template", prompt)
      assert.matches("PR TEMPLATE:", prompt)
      assert.matches("PR template", prompt)
      assert.matches("CHANGES:", prompt)
      assert.matches("test diff content$", prompt) -- Diff should be at the end
    end)
    
    it("should generate a PR prompt with template, diff and motivation", function()
      local template = "PR template"
      local diff = "test diff content"
      local motivation = "implementing new feature"
      local prompt = prompts.pr_prompt(template, diff, motivation)
      
      assert.is_string(prompt)
      assert.matches("Fill in the PR template", prompt)
      assert.matches("PR TEMPLATE:", prompt)
      assert.matches("PR template", prompt)
      assert.matches("implementing new feature", prompt)
      assert.matches("CHANGES:", prompt)
      assert.matches("test diff content$", prompt) -- Diff should be at the end
    end)
    
    it("should generate PR prompt without motivation when nil", function()
      local template = "PR template"
      local diff = "test diff content"
      local prompt = prompts.pr_prompt(template, diff, nil)
      
      assert.is_string(prompt)
      assert.matches("Fill in the PR template", prompt)
      assert.matches("PR TEMPLATE:", prompt)
      assert.matches("PR template", prompt)
      assert.matches("CHANGES:", prompt)
      assert.matches("test diff content$", prompt) -- Diff should be at the end
    end)
  end)
end)