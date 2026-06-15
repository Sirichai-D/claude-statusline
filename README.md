# Claude Code StatusLine

Status line for [Claude Code](https://claude.ai/code) on Windows showing model name, context usage, rate-limit bars, and current directory.

```
Claude Opus 4 | ctx:42% | 5h:[##--------]20% | 7d:[#---------]8% | C:/Users/you/project
```

## Install

```powershell
irm https://raw.githubusercontent.com/<YOUR_USERNAME>/claude-statusline/main/install.ps1 | iex
```

Restart Claude Code after running.

## What it shows

| Field | Example |
|-------|---------|
| Model name | `Claude Opus 4` |
| Context window usage | `ctx:42%` |
| 5-hour rate limit | `5h:[##--------]20%` |
| 7-day rate limit | `7d:[#---------]8%` |
| Current directory | `C:/Users/you/project` |

Rate-limit bars are hidden when not on a Claude.ai subscription session.
