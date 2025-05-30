local M = {}

-- Commit message prompt template
function M.commit_prompt(diff, motivation)
  local base_prompt = [[
Generate a git commit message in Conventional Commits format based on this diff.
Do not include explanations, notes, or any text outside of the commit message itself.
Your response should be ONLY the commit message, ready to use as-is.

Format:
<type>[optional scope]: <description>

[optional body]

Available types:
- feat: A new feature
- fix: A bug fix
- docs: Documentation changes
- style: Changes that don't affect code meaning
- refactor: Code change neither fixing a bug nor adding a feature
- perf: Performance improvements
- test: Adding/fixing tests
- chore: Changes to build process or auxiliary tools

Guidelines:
- Subject line: Brief, imperative mood, focus on what was changed
- Body (optional): Add when the change is complex or needs explanation
- Include body for significant changes, breaking changes, or when context helps
- Separate subject and body with a blank line
- Wrap body at 72 characters]]

  if motivation then
    base_prompt = base_prompt .. [[

MOTIVATION:
Consider this motivation when crafting the commit message: ]] .. motivation
  end

  return base_prompt .. [[

DIFF:
]] .. diff
end

-- PR description prompt template
function M.pr_prompt(template, diff_or_commits, motivation)
  local base_prompt = [[
Fill in the PR template below based on the provided git diff or commit messages.
Focus on being specific, explaining why changes were made, and providing helpful context for reviewers.
Your response should exactly follow the template format without additional commentary.]]

  if motivation then
    base_prompt = base_prompt .. [[

MOTIVATION:
Consider this motivation when filling out the PR template: ]] .. motivation
  end

  return base_prompt .. [[

PR TEMPLATE:
]] .. template .. [[

CHANGES:
]] .. diff_or_commits
end

return M