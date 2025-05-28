local M = {}

-- Commit message prompt template
function M.commit_prompt(diff)
  return [[
You are an expert developer writing a clear, concise git commit message.

Below is a git diff of changes that need to be committed. Please generate a commit message following
the Conventional Commits format:

<type>[optional scope]: <description>

[optional body]

[optional footer(s)]

Types include:
- feat: A new feature
- fix: A bug fix
- docs: Documentation changes
- style: Changes that don't affect code meaning
- refactor: Code change neither fixing a bug nor adding a feature
- perf: Performance improvements
- test: Adding/fixing tests
- chore: Changes to build process or auxiliary tools

Guidelines:
1. Keep the description short (less than 72 characters)
2. Use imperative mood ("Add feature" not "Added feature")
3. Describe what was changed and why, not how
4. Focus on the most significant change if there are multiple
5. Omit "and" in the description (use bullets in body for multiple changes)
6. Use body for more details if needed

Here's the diff:

]] .. diff
end

-- PR description prompt template
function M.pr_prompt(template, diff_or_commits)
  return [[
You are an expert developer writing a clear, concise pull request description.
Please fill in the PR template below based on the changes in the provided git diff or commit messages.

Guidelines:
1. Be specific about what changes were made
2. Explain why the changes were necessary
3. Mention any important technical details
4. List any dependencies that were added
5. Provide context for reviewers
6. Focus on information that would be helpful for code review

PR Template:
]] .. template .. [[

Here are the changes:

]] .. diff_or_commits
end

return M