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
      assert.matches("You are an expert developer", prompt)
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
      assert.matches("You are an expert developer", prompt)
      assert.matches("PR template", prompt)
      assert.matches("test diff content$", prompt) -- Diff should be at the end
    end)
  end)
end)