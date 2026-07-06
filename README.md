# fe-agent-pack

A **portable personal frontend asset pack** for Claude Code. It encodes *your*
senior-FE judgment and workflows as skills, agents, and commands — so when you
change jobs, you bring your tooling with you instead of rebuilding it.

> **Design principles**
> - **Model-agnostic** — no model is hardcoded. Runs on whatever model your next
>   employer's policy allows (fable / sonnet / opus / …).
> - **Company-neutral** — contains no company code, secrets, or proper nouns.
>   Safe to keep in a public repo.
> - **Complements, doesn't duplicate** — assumes generic FE skills
>   (`frontend-ui-engineering`, `fe-anti-pattern-guard`, `react-doctor`, …) already
>   exist. This pack encodes *your process and taste*, not general knowledge.

## What's inside

| Asset | Type | What it does |
|-------|------|--------------|
| `fe-onboarder` | agent | Maps an unfamiliar repo → `ORIENTATION.md` (read-only on source). Day-one at a new job. |
| `fe-review-checklist` | skill | Your PR review workflow: triage order, severity labels, what to block on. |
| `fe-scaffold` | skill | Scaffolds a component/feature with your colocation, naming, and test conventions. |
| `/fe-audit` | command | Fast accessibility + performance (Core Web Vitals) audit with severity-rated findings. |

## Install

```bash
git clone <your-remote> ~/fe-agent-pack   # or keep it wherever
cd ~/fe-agent-pack
./install.sh
```

`install.sh` creates **symlinks** into `~/.claude/{agents,commands,skills}`. It is:
- **Idempotent** — re-running is a no-op for already-linked assets.
- **Safe** — it never clobbers unrelated files or symlinks; it only manages links
  that point back into this repo.
- **Overridable** — `CLAUDE_HOME=/custom/path ./install.sh` targets a different config dir.

Uninstall removes only this pack's links:

```bash
./uninstall.sh
```

## Extend

Add your own asset, then re-run `./install.sh`:

- Skill: `skills/<name>/SKILL.md` (with `name` + `description` frontmatter)
- Agent: `agents/<name>.md`
- Command: `commands/<name>.md`

Every shipped asset has `TODO(personalize)` markers — that's where you inject your
actual stack, taste, and the questions you always ask. **The pack is a template of
your judgment; personalize it and it becomes genuinely yours.**

## Why symlinks (not copies)

Editing an asset here updates it live in `~/.claude`. One source of truth, version
controlled, and portable to any machine with a single `install.sh`.
