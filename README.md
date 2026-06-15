# Claude Code StatusLine

Status line for [Claude Code](https://claude.ai/code) on Windows showing model name, context usage, rate-limit bars with reset countdown, and current directory.

```
Sonnet 4.6 | ctx:27% | 5h:[######----]58%(RST 10m) | 7d:[#---------]6%(RST 109h00m) | C:/Users/you/project
```

## Install

```powershell
irm https://raw.githubusercontent.com/Sirichai-D/claude-statusline/main/install.ps1 | iex
```

Restart Claude Code after running.

## What it shows

| Field | Example |
|-------|---------|
| Model name | `Sonnet 4.6` |
| Context window usage | `ctx:27%` |
| 5-hour rate limit | `5h:[######----]58%(RST 10m)` |
| 7-day rate limit | `7d:[#---------]6%(RST 109h00m)` |
| Current directory | `C:/Users/you/project` |

- Reset countdown shows minutes (`RST 10m`) when under 1 hour, otherwise hours+minutes (`RST 109h00m`)
- Rate-limit bars are hidden when not on a Claude.ai subscription session
