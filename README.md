# Claude Usage Widget

An Elixir CLI tool that fetches and displays your Claude AI usage statistics. Perfect for embedding in status bars, widgets, or quick terminal checks.

## Installation

### Prerequisites

- Elixir 1.18 or later
- Erlang/OTP

### Build

```bash
mix deps.get
mix escript.build
```

This produces a `claude_usage_widget` executable in the project directory.

### Install globally (optional)

```bash
sudo mv claude_usage_widget /usr/local/bin/
# or
mv claude_usage_widget ~/.local/bin/
```

## Configuration

Create a config file at `~/.config/claude_usage/config.json`:

```bash
mkdir -p ~/.config/claude_usage
```

```json
{
  "session_token": "sk-ant-sid-...",
  "organization_id": "your-org-id"
}
```

### How to get your credentials

1. Login to https://claude.ai
2. Open Developer Tools (F12)
3. Navigate to: **Application** → **Storage** → **Cookies** → **https://claude.ai**
4. Find the `sessionKey` cookie
5. Copy its value (starts with `sk-ant-sid-...`)
6. Go to https://claude.ai/settings/account
7. Copy the **Organization ID**

## Usage

### Verbose mode (default)

```bash
claude_usage_widget
```

Output:
```
5-hour usage:  11.0% (resets: 2025-12-12 14:59 UTC)
Weekly usage:   7.0% (resets: 2025-12-17 07:59 UTC)
Sonnet usage:   0.0% (no reset scheduled)
```

### Short mode

```bash
claude_usage_widget --short
claude_usage_widget -s
```

Output:
```
5h: 11.0% | 7d: 7.0%
```

Short mode is ideal for status bars and widgets where space is limited.

## Widget Integration Examples

### Waybar (Wayland)

```json
{
  "custom/claude": {
    "exec": "claude_usage_widget -s",
    "interval": 300,
    "format": "Claude: {}"
  }
}
```

### i3blocks

```ini
[claude]
command=claude_usage_widget -s
interval=300
```

### tmux status bar

```bash
set -g status-right '#(claude_usage_widget -s)'
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0    | Success |
| 1    | Error (config missing, API failure, etc.) |

## License

MIT
