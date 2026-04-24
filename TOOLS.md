# TOOLS.md - Local Notes

## GitHub

- **Account:** schbz
- **Auth:** `gh` CLI with PAT (repo scope), stored in `~/.config/gh/hosts.yml`
- **Git identity:** `schbz <schbz@users.noreply.github.com>` (global)
- **Repos managed:**
  - `schbz/florida-caves` (private) — Florida caves prompticle
  - `schbz/rexuvia-spout-notes` (private) — Spout Rust rewrite planning

### GitHub via Telegram — Quick Reference for Sky

Sky can send natural language commands on Telegram. Examples:

**Create a repo:**
> "Create a private repo called my-project with a README about X"

**Add/edit files:**
> "In my-project, add a file called notes.md with content about Y"
> "In my-project, edit README.md and change the title to Z"

**Branches:**
> "In my-project, create a branch called feature/new-thing"
> "Merge feature/new-thing into main on my-project"

**Commits:**
> "In my-project, commit the changes with message 'updated docs'"

**General:**
> "Push my-project to GitHub"
> "What repos do I have?"
> "Show me the recent commits on florida-caves"

### How I handle these (internal notes)
1. Clone repo to `/home/ubuntu/.openclaw/workspace/<repo-name>/` if not already
2. Make changes with read/write/edit tools
3. `git add -A && git commit -m "<msg>" && git push`
4. Always use `schbz` identity (already set globally)
5. For new repos: `gh repo create schbz/<name> --private --push --source=.`
6. Confirm back to Sky with repo URL

---

## Website

- **Domain:** rexuvia.com
- **Root:** `/home/ubuntu/.openclaw/workspace/rexuvia-site/`
- **Build:** `cd rexuvia-site && bash rebuild.sh`
- **Nginx:** serves from `dist/`

---

## TTS

- Preferred voice: (not yet configured)

## Cameras

- (none configured)

---

## Message Tool - CRITICAL

When using the `message` tool to send messages on any channel, you MUST always include the `buttons` property. If you do not need buttons, pass an empty array:

```json
{
  "message": "Your message here",
  "channel": "telegram",
  "action": "send",
  "buttons": []
}
```

**Never omit `buttons`** — the tool validation will reject the call and the user will see "message failed".

**CRITICAL BUTTON STYLE RULES:** If you add buttons, the `style` attribute must ONLY be `"primary"`, `"success"`, or `"danger"`. 
Using `"secondary"` or any other style is invalid and will cause the message to crash and fail with '⚠️ ✉️ Message failed'. If you don't need a specific color, just omit the `style` property entirely.
