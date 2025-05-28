# hum

![hum logo](./static/hummingbird.png)

**hum** is a Neovim plugin that uses the Claude API to generate clean, natural-language commit messages and pull request descriptions — guided by your repository’s PR template.

Let Claude do the talking while you keep coding.

---

## Features

* 📝 Generate [Conventional Commits](https://www.conventionalcommits.org/) automatically
* 📋 Craft full pull request descriptions based on your repo's PR template
* 🤖 Powered by Anthropic Claude for smart, context-aware summarization
* 🧠 Works with your current buffer, diff, or staged changes
* 🪶 Minimal, fast, and written in Lua

---

## Installation

Use your favorite plugin manager:

### lazy.nvim

```lua
{
  "simiancreative/hum",
  config = function()
    require("hum").setup({
      claude_api_key = os.getenv("CLAUDE_API_KEY"),
    })
  end
}
```

### packer.nvim

```lua
use {
  "simiancreative/hum",
  config = function()
    require("hum").setup({
      claude_api_key = os.getenv("CLAUDE_API_KEY"),
    })
  end
}
```

---

## Usage

Generate a commit message for staged changes:

```
:HumCommit
```

Generate a PR description based on your current branch diff:

```
:HumPR
```

---

## Configuration

```lua
require("hum").setup({
  claude_api_key = os.getenv("CLAUDE_API_KEY"),
  model = "claude-3-haiku", -- or claude-3-sonnet, claude-2, etc.
  pr_template_path = ".github/PULL_REQUEST_TEMPLATE.md",
})
```

---

## Philosophy

Like its namesake, **hum** is small, fast, and purposeful — a quiet companion that helps your code speak clearly.

> Let your code hum.

---

## License

MIT © SimianCreative

