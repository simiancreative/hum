local M = {}

-- Commit message prompt template
function M.commit_prompt(diff)
  return [[
Generate a concise git commit message in Conventional Commits format based on this diff.
Do not include explanations, notes, or any text outside of the commit message itself.
Your response should be ONLY the commit message, ready to use as-is.

Format: <type>[optional scope]: <description>

Available types:
- feat: A new feature
- fix: A bug fix
- docs: Documentation changes
- style: Changes that don't affect code meaning
- refactor: Code change neither fixing a bug nor adding a feature
- perf: Performance improvements
- test: Adding/fixing tests
- chore: Changes to build process or auxiliary tools

Keep the message brief, use imperative mood, and focus on what was changed and why.

DIFF:
]] .. diff
end

-- PR description prompt template
function M.pr_prompt(template, diff_or_commits)
  return [[
Fill in the PR template below based on the provided git diff or commit messages.
Focus on being specific, explaining why changes were made, and providing helpful context for reviewers.
Your response should exactly follow the template format without additional commentary.

PR TEMPLATE:
]] .. template .. [[

CHANGES:
]] .. diff_or_commits
end

return M