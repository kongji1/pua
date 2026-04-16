# Installing PUA Skill for Codex

Force AI to exhaust every possible solution before giving up. Installs via native skill discovery (`~/.codex/skills/`).

## Prerequisites

- Git

## Installation

### Local checkout already present

If you already have a local copy of this repo, use the checked-in installer instead of cloning again.

### Windows (local checkout)

```powershell
cd <path-to-your-local-pua-repo>
powershell -NoProfile -ExecutionPolicy Bypass -File .\install-codex-pua.ps1 -Force
```

Or double-click:

```text
install-codex-pua.cmd
```

This installer creates:

- a junction from `~/.codex/skills/pua` to `codex/pua`
- a prompt hard link when the repo and `~/.codex` are on the same volume
- a prompt file copy fallback when they are on different volumes

That cross-volume fallback matters on Windows because hard links cannot span drives.

### macOS / Linux

```bash
# 1. Clone the repo
git clone https://github.com/tanweai/pua.git ~/.codex/pua

# 2. Create skill symlink (enables auto-discovery)
mkdir -p ~/.codex/skills
ln -s ~/.codex/pua/codex/pua ~/.codex/skills/pua

# 3. Install /prompts:pua trigger
mkdir -p ~/.codex/prompts
ln -s ~/.codex/pua/commands/pua.md ~/.codex/prompts/pua.md

# 4. Restart Codex
```

### Windows (PowerShell)

```powershell
# 1. Clone the repo
git clone https://github.com/tanweai/pua.git "$env:USERPROFILE\.codex\pua"

# 2. Create skill junction (enables auto-discovery)
New-Item -ItemType Directory -Force "$env:USERPROFILE\.codex\skills"
cmd /c mklink /J "$env:USERPROFILE\.codex\skills\pua" "$env:USERPROFILE\.codex\pua\codex\pua"

# 3. Install /prompts:pua trigger
New-Item -ItemType Directory -Force "$env:USERPROFILE\.codex\prompts"
if ((Split-Path "$env:USERPROFILE\.codex\pua\commands\pua.md" -Qualifier) -eq (Split-Path "$env:USERPROFILE\.codex\prompts\pua.md" -Qualifier)) {
  cmd /c mklink /H "$env:USERPROFILE\.codex\prompts\pua.md" "$env:USERPROFILE\.codex\pua\commands\pua.md"
} else {
  Copy-Item "$env:USERPROFILE\.codex\pua\commands\pua.md" "$env:USERPROFILE\.codex\prompts\pua.md" -Force
}

# 4. Restart Codex
```

If your repo checkout and `~/.codex` live on different drives, use the copy fallback shown above because Windows hard links cannot cross volumes.

## Verify

Type `$pua` in a Codex conversation. If the skill is loaded, you'll see it activate.

Or check directly:
```bash
# macOS / Linux
ls ~/.codex/skills/pua/SKILL.md

# Windows PowerShell
Test-Path "$env:USERPROFILE\.codex\skills\pua\SKILL.md"
```

## Trigger Methods

| Method | Command | Requires |
|--------|---------|----------|
| Auto trigger | No action needed, matches by description | SKILL.md |
| Direct call | Type `$pua` in conversation | SKILL.md |
| Manual prompt | Type `/prompts:pua` in conversation | SKILL.md + prompts/pua.md |

## Language Variants

| Language | Skill path |
|----------|------------|
| 🇨🇳 Chinese (default) | `codex/pua/SKILL.md` |
| 🇺🇸 English (PIP) | `codex/pua-en/SKILL.md` |
| 🇯🇵 Japanese | `codex/pua-ja/SKILL.md` |

To install a different language variant, replace `pua` with `pua-en` or `pua-ja` in the symlink/junction step:

```bash
# Example: English variant (macOS/Linux)
ln -s ~/.codex/pua/codex/pua-en ~/.codex/skills/pua-en
```

## Update

```bash
cd ~/.codex/pua
git pull
```

The skill symlink or junction automatically picks up the latest version after `git pull`.

If your prompt was installed as a hard link, it updates automatically too.
If your prompt was installed as a copied file, re-run the installer or copy `commands/pua.md` again after updating.

## Uninstall

### macOS / Linux

```bash
rm ~/.codex/skills/pua
rm ~/.codex/prompts/pua.md
rm -rf ~/.codex/pua
```

### Windows (PowerShell)

```powershell
Remove-Item "$env:USERPROFILE\.codex\skills\pua"
Remove-Item "$env:USERPROFILE\.codex\prompts\pua.md"
Remove-Item -Recurse "$env:USERPROFILE\.codex\pua"
```
