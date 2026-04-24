# District 9 Sequel — Agent Swarm Screenplay Project

## Overview
A multi-agent collaborative effort to produce a feature-length screenplay sequel to District 9 (2009).

## Creative Brief
- **Setting:** Orlando, Florida (present day)
- **Key Plot Point:** Christopher Johnson has returned with more ships
- **Tone:** Gritty, grounded sci-fi with social commentary (faithful to original)
- **Format:** Standard screenplay format (sluglines, action, dialogue)
- **Target Length:** 110-120 pages (~feature length)
- **Style:** Documentary/found-footage elements mixed with traditional cinematography (like the original's evolution)

## Agent Pipeline

### Phase 1: Foundation
1. **World Builder** (Opus 4.6) — Setting bible: Orlando geography, political climate, how prawn integration/segregation has evolved, Christopher's return scenario, new ship lore
2. **Character Architect** (GPT-5 Pro) — Full character profiles: Wikus (prawn form, 17 years later), Christopher, new human & prawn characters, antagonists, arcs

### Phase 2: Structure
3. **Story Architect** (Grok 4) — 3-act structure, scene-by-scene breakdown, thematic throughlines, setpieces
4. **Critic #1** (Gemini 2.5 Pro) — Review Phase 1+2 outputs, identify weaknesses, plot holes, missed opportunities

### Phase 3: First Draft
5. **Act I Writer** (Opus 4.6) — Pages 1-35, screenplay format
6. **Act II Writer** (GPT-5 Pro) — Pages 36-85, screenplay format
7. **Act III Writer** (Grok 4) — Pages 86-120, screenplay format

### Phase 4: Review & Revision
8. **Script Doctor** (DeepSeek R1) — Deep analysis of full draft: pacing, character consistency, dialogue authenticity, thematic coherence
9. **Dialogue Specialist** (Opus 4.6) — Rewrite pass focused on voice, subtext, memorable lines

### Phase 5: Final Polish
10. **Final Critic** (Gemini 2.5 Pro) — Final review with detailed notes
11. **Final Assembly** (Opus 4.6) — Incorporate notes, produce final polished screenplay

## Models Used
| Role | Model | Alias |
|------|-------|-------|
| World Builder | anthropic/claude-opus-4-6 | opus |
| Character Architect | openrouter/openai/gpt-5-pro | gpt5pro |
| Story Architect | openrouter/x-ai/grok-4 | grok |
| Critic #1 | google/gemini-2.5-pro | pro |
| Act I Writer | anthropic/claude-opus-4-6 | opus |
| Act II Writer | openrouter/openai/gpt-5-pro | gpt5pro |
| Act III Writer | openrouter/x-ai/grok-4 | grok |
| Script Doctor | openrouter/deepseek/deepseek-r1-0528 | r1 |
| Dialogue Specialist | anthropic/claude-opus-4-6 | opus |
| Final Critic | google/gemini-2.5-pro | pro |
| Final Assembly | anthropic/claude-opus-4-6 | opus |

## Workspace Structure
```
district9-sequel/
├── PROJECT.md              ← This file
├── planning/
│   ├── world-bible.md      ← Setting, lore, rules
│   ├── characters.md       ← Character profiles & arcs
│   ├── story-outline.md    ← 3-act structure & scene breakdown
│   └── critique-1.md       ← First critic pass
├── drafts/
│   ├── act1-draft1.md      ← First draft Act I
│   ├── act2-draft1.md      ← First draft Act II
│   ├── act3-draft1.md      ← First draft Act III
│   ├── full-draft1.md      ← Assembled first draft
│   ├── script-doctor.md    ← Script doctor analysis
│   ├── dialogue-pass.md    ← Dialogue rewrite notes
│   ├── full-draft2.md      ← Revised draft
│   └── FINAL-SCREENPLAY.md ← Final polished screenplay
├── critiques/
│   ├── critique-1.md       ← Post-outline critique
│   ├── script-doctor.md    ← Full draft analysis
│   └── final-critique.md   ← Final review
├── characters/             ← Individual character deep-dives
├── worldbuilding/          ← Extended lore & research
└── logs/                   ← Agent thinking records & session logs
```
