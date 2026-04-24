# ModelShow Results
**Date:** 2026-03-08T00:30:00Z
**Prompt:** Give me a concise reference guide for a long time windows user switching to macOS
**Models:** google/gemini-2.5-pro, openrouter/openai/gpt-5, openrouter/x-ai/grok-4, openrouter/moonshotai/kimi-k2.5
**Judge:** openrouter/google/gemini-3.1-pro-preview
**Judging Mode:** Blind (model identities hidden from judge)

---

## Rankings

### 🏆 **openrouter/openai/gpt-5** — 9.5/10

**Judge's Assessment:**
Exceptional organization and clarity. Covers all essential transition concepts with the right level of detail — not too basic for a power user, not overwhelming. The parallel structure (Windows term → macOS equivalent) is exactly what a switcher needs. Includes keyboard shortcuts, file system differences, and app ecosystem differences in a scannable format.

**Full Response:**
# macOS Quick Reference for Windows Switchers

## Core Concepts
| Windows | macOS |
|---------|-------|
| Start Menu | Spotlight (⌘Space) or Launchpad |
| Task Manager | Activity Monitor |
| File Explorer | Finder |
| Control Panel | System Settings |
| Right-click | Right-click or Ctrl+click |
| Alt+F4 | ⌘Q (quit), ⌘W (close window) |
| Ctrl+Z/X/C/V | ⌘Z/X/C/V |
| Windows key | Command (⌘) key |
| Alt | Option (⌥) |

## Essential Shortcuts
- **⌘Space** — Spotlight search (find anything)
- **⌘Tab** — Switch apps (like Alt+Tab)
- **⌘`** — Switch windows within same app
- **⌘,** — Open app Preferences
- **⌘Shift+3/4/5** — Screenshot tools
- **⌃⌘Space** — Emoji picker
- **⌘Option+Esc** — Force quit (like Ctrl+Alt+Del)

## File System
- No drive letters (C:, D:). One unified file tree at /
- Home folder: /Users/yourname (like C:\Users\yourname)
- Apps go in /Applications (drag to install from .dmg)
- Uninstall: drag app from /Applications to Trash
- Hidden files: ⌘Shift+. to toggle in Finder

## App Equivalents
| Windows App | macOS App |
|-------------|----------|
| Notepad | TextEdit |
| Paint | Preview (basic) / Pixelmator |
| Windows Media Player | QuickTime / Music |
| IE/Edge | Safari |
| Outlook | Mail / Outlook for Mac |
| Word/Excel/PPT | Pages/Numbers/Keynote or Office for Mac |

## Tips for Switchers
1. **Window management**: Use Mission Control (F3 or swipe up with 3 fingers)
2. **Closing ≠ Quitting**: Red X closes the window but app stays running. Use ⌘Q to quit.
3. **Install apps**: Mac App Store or .dmg files (mount, drag to Applications)
4. **Clipboard**: Same Ctrl+C/V but with ⌘ instead
5. **Terminal**: Fully-featured Unix terminal at Applications > Utilities > Terminal
6. **iCloud integration**: Desktop and Documents can sync across devices
7. **Homebrew**: Package manager for developer tools (brew.sh)

---

### 🥈 **google/gemini-2.5-pro** — 8.5/10

**Judge's Assessment:**
Very comprehensive coverage with good depth. Excellent on system-level differences and keyboard shortcuts. Slightly verbose in places — could be tighter for a 'concise' guide. The section on Finder vs Explorer is particularly well-done.

**Full Response:**
# Switching from Windows to macOS: Reference Guide

## The Basics
macOS is Unix-based, which means the file system and many conventions differ from Windows. The learning curve is real but manageable.

## Key Keyboard Differences
The biggest adjustment is the ⌘ (Command) key replacing Ctrl for most shortcuts:
- Copy/Paste: ⌘C / ⌘V
- Undo: ⌘Z
- Select All: ⌘A
- Save: ⌘S
- Find: ⌘F
- New window/tab: ⌘N / ⌘T

The Option key (Alt equivalent) adds functionality, and Control still exists but is used less.

## Window & App Management
- **Traffic lights**: Red = close window, Yellow = minimize, Green = fullscreen
- **⌘Q** quits an app entirely (red X does NOT quit)
- **⌘Tab**: Switch between open apps
- **Mission Control** (F3): See all open windows
- **Spaces**: Virtual desktops, create in Mission Control

## Finding Things
- **Spotlight** (⌘Space): Universal search — apps, files, calculations, web
- **Finder**: File manager (like Explorer). Sidebar has favorites, Locations
- Recent items: Apple menu > Recent Items

## System Settings
- Equivalent to Control Panel: Apple menu > System Settings
- App-specific settings: In each app, use ⌘, (Preferences)

## Installing & Removing Apps
- Drag .dmg-based apps to /Applications folder to install
- Delete by dragging to Trash (for simple apps)
- Complex apps: use their uninstaller or AppCleaner

## File System Highlights
- No drive letters
- User home: ~/  (expands to /Users/username)
- Show hidden files: ⌘⇧. in Finder

---

### 🥉 **openrouter/x-ai/grok-4** — 8.0/10

**Judge's Assessment:**
Clean, readable structure with good Windows-to-macOS mapping. Strong on the conceptual differences. Misses some important power-user shortcuts and the app ecosystem section is thinner than the top two. Good overall but not as complete.

**Full Response:**
# Windows → macOS Switcher Guide

## Mental Model Shift
- macOS is Unix. No registry, no drive letters, permissions matter.
- Apps are self-contained bundles. Installing = copying to /Applications.
- The Dock is permanent (like taskbar), not just active apps.

## Keyboard Remapping
| Action | Windows | macOS |
|--------|---------|-------|
| Copy | Ctrl+C | ⌘C |
| Paste | Ctrl+V | ⌘V |
| Undo | Ctrl+Z | ⌘Z |
| Find | Ctrl+F | ⌘F |
| Switch apps | Alt+Tab | ⌘Tab |
| Lock screen | Win+L | ⌃⌘Q |
| Task manager | Ctrl+Shift+Esc | ⌘⌥Esc |
| Screenshot | PrtSc | ⌘⇧3 (full) / ⌘⇧4 (region) |

## Navigation
- **Spotlight** (⌘Space): Your new best friend
- **Finder** = Explorer, but more limited by default
- **Cmd+Delete**: Move to Trash (like Delete key in Explorer)

## Common Gotchas
1. Closing a window doesn't quit the app (watch the Dock dot)
2. macOS updates are smooth, no restart loops
3. Right-click works fine, or use two-finger tap on trackpad
4. No maximize button by default (green = fullscreen)
5. Fonts look different due to sub-pixel rendering differences

---

###  **openrouter/moonshotai/kimi-k2.5** — 7.5/10

**Judge's Assessment:**
Decent coverage of the basics. Well-organized but lacks depth in several areas. The shortcuts table is a nice touch. Skips several important topics (file system navigation, app installation, developer tools) that a long-time Windows power user would need. Adequate but not comprehensive enough for the stated goal.

**Full Response:**
# macOS Reference for Windows Users

## Key Differences at a Glance

**System Navigation**
- Start Menu → Spotlight Search (⌘ + Space)
- Taskbar → Dock (bottom of screen)
- File Explorer → Finder
- Control Panel → System Preferences/Settings
- Task Manager → Activity Monitor

**Keyboard Shortcuts**
- Ctrl → ⌘ (Command) for most shortcuts
- Alt → ⌥ (Option)
- Windows Key → no direct equivalent (⌘ handles most functions)
- Alt+F4 → ⌘Q (quit app) or red dot
- Ctrl+Alt+Del → ⌘⌥Esc (Force Quit)

**File Management**
- No C: drive; everything under /
- Right-click in Finder for context menu
- Drag apps to Applications to install
- Delete = move to Trash, then empty

**Common Apps**
- Notepad → TextEdit
- Calculator → Calculator (same!)
- Paint → Preview
- IE/Edge → Safari

## Quick Tips
- ⌘Tab switches apps, ⌘` switches windows in same app
- Spotlight can do math, search files, open apps
- iCloud Drive integrates like OneDrive
- Homebrew for command-line tools

---

## Judge's Overall Assessment

## Judge's Evaluation: Windows to macOS Reference Guide

### Response A → gpt5
**Score: 9.5/10**
Exceptional organization and clarity. Covers all essential transition concepts with the right level of detail — not too basic for a power user, not overwhelming. The parallel structure (Windows term → macOS equivalent) is exactly what a switcher needs. Includes keyboard shortcuts, file system differences, and app ecosystem differences in a scannable format. The Homebrew mention is a great touch for power users.

### Response B → pro
**Score: 8.5/10**
Very comprehensive coverage with good depth. Excellent on system-level differences and keyboard shortcuts. Slightly verbose in places — could be tighter for a 'concise' guide. The section on Finder vs Explorer is particularly well-done. Missing some of the power-user tips that gpt5 included.

### Response C → grok
**Score: 8.0/10**
Clean, readable structure with good Windows-to-macOS mapping. Strong on the conceptual differences. Misses some important power-user shortcuts and the app ecosystem section is thinner than the top two. Good overall but not as complete.

### Response D → kimi
**Score: 7.5/10**
Decent coverage of the basics. Well-organized but lacks depth in several areas. The shortcuts table is a nice touch. Skips several important topics (file system navigation, app installation, developer tools) that a long-time Windows power user would need. Adequate but not comprehensive enough for the stated goal.

## Overall Assessment

All four models produced useful macOS switcher guides, but there's a clear performance gradient. The top performer (GPT-5) distinguished itself by combining exhaustive coverage with genuinely scannable formatting — the side-by-side tables work extremely well for this use case. It's the only response that explicitly addresses the 'long-time power user' aspect of the prompt by including Terminal access and Homebrew.

The middle tier (Claude Pro, Grok) shows strong fundamentals but doesn't fully address the power-user dimension. Both cover the keyboard remapping and conceptual shift well, but stop short of the developer-adjacent tips that distinguish a casual switcher guide from a power-user reference.

Kimi's response is the weakest, feeling more like a checklist than a reference guide. It covers the surface but lacks the depth needed to actually help someone make the transition smoothly.

Key differentiator: The best responses acknowledged that macOS's 'close window ≠ quit app' behavior is the #1 gotcha for Windows switchers, and addressed it prominently. All four mentioned it, which shows good domain awareness across the board.

Note: deepseek timed out and was not evaluated.

---

## Blind Judging Key (Audit)

- Response A → openrouter/openai/gpt-5
- Response B → google/gemini-2.5-pro
- Response C → openrouter/x-ai/grok-4
- Response D → openrouter/moonshotai/kimi-k2.5

---

## Metadata

- **Total Duration:** 68.0s
- **Successful Models:** 4
- **Failed Models:** 0
- **Timed Out:** deepseek
