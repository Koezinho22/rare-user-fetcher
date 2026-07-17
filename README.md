# Rare User Fetcher v2.0

Hunt for rare short usernames on **Roblox** and **Discord** straight from CMD.

---

## Requirements

- Windows 10/11 (uses PowerShell 5.1 internally)
- Internet connection
- No installs needed

## Quick Start

Double-click `RareUserFetcher.bat` or run from CMD.

## Menu

| Option | What it does |
|--------|-------------|
| **1 — Check Rare Usernames** | Hunt for available short usernames |
| **2 — See What's Available** | View all found names, sorted by rarity |
| **3 — Exit** | Close |

## Hunting Modes (Option 1)

| Mode | Description |
|------|-------------|
| **A** | Hunt **3-letter** names — OG tier, extremely rare |
| **B** | Hunt **4-letter** names — very rare |
| **C** | Hunt **5-letter** names — rare |
| **D** | Custom length (3–8) |
| **E** | Check one specific username |
| **F** | Bulk check from a `.txt` file (one name per line) |

### Hunt Settings

When hunting (A–D), you pick:

1. **Character set** — letters only, letters+numbers, letters+underscore, or all
2. **Platform** — Roblox only, Discord only, or both
3. **Amount** — how many random names to generate and check (up to 200)

The generator always starts names with a letter (required by both platforms).

## Rarity Tiers (in View mode)

| Stars | Length | Tier |
|-------|--------|------|
| ★★★ | 3 letters | OG |
| ★★ | 4 letters | Very Rare |
| ★ | 5 letters | Rare |

## Output

All available names save to `rare_available.txt` next to the script:

```
ROBLOX|abc|AVAILABLE
DISCORD|xy9z|AVAILABLE
```

## APIs Used

- **Roblox** — `auth.roblox.com/v1/usernames/validate` (public, accurate)
- **Discord** — `unique-username/username-attempt-unauthed` (public Pomelo check, may rate-limit)

Discord rate limits are handled automatically with a 5-second cooldown.

## Tips

- 3-letter names are almost all taken on Roblox — but not all. Persistence pays off.
- Use "letters + numbers" charset for better odds on short names.
- Discord rate-limits faster than Roblox — keep batches under 50 for Discord.
- Save your finds — option 2 shows everything grouped by platform and rarity.

## License

MIT
