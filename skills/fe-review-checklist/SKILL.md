---
name: fe-review-checklist
description: A senior frontend engineer's personal PR review workflow — how to triage a diff, what to block on vs. comment on, and severity rating. Use when reviewing a frontend pull request or your own diff before pushing. Encodes review process and judgment, not a generic lint list.
---

# fe-review-checklist

This is **how I review a frontend PR** — the process and the judgment calls, not a
restatement of lint rules. (Pattern-level anti-patterns are already covered by the
`fe-anti-pattern-guard` and `react-doctor` skills; this skill is about the *review
act itself* — what to look at first, what deserves a blocking comment, and how to
phrase it.)

## Review order (cheapest signal first)
1. **PR description & scope.** Does the diff match the stated intent? Flag scope
   creep before reading code — it's the highest-leverage comment.
2. **Public surface.** Props/type contracts, exported hooks, API shapes. Interface
   mistakes are expensive to unwind later, so review them before implementation.
3. **State & data flow.** Where does new state live, and is that the right altitude?
   Server data in `useState`, prop-drilling past 2 levels, or a new global store for
   local concerns are all worth a conversation.
4. **Rendering behavior.** New effects, dependency arrays, list `key`s, and whether
   `memo`/`useMemo`/`useCallback` are earning their complexity or cargo-culted.
5. **User-facing states.** Loading, empty, error, and disabled states — the paths
   that never show up in the happy-path screenshot.
6. **Accessibility.** Semantic elements over `div` soup, keyboard reachability,
   focus management on route/modal changes, labels on inputs. ARIA only where native
   semantics fall short.
7. **Tests.** Do they test behavior a user cares about, or implementation details
   that will break on the next refactor?

## Severity rating (put this label on every comment)
- **[block]** — correctness bug, a11y regression, insecure handling of user input,
  or a public-interface mistake. Merge should wait.
- **[should]** — clear maintainability/perf issue with a concrete downside. Author
  decides, but I want a reply.
- **[nit]** — style/preference. Never block; prefix explicitly so it reads as optional.
- **[question]** — I don't understand something yet; ask before asserting.

## How to phrase it
- Lead with the concrete downside ("this re-renders the whole list on every keystroke"),
  not the rule ("don't do this").
- Propose the alternative or ask — never just "this is wrong".
- Praise genuinely good decisions; review is a two-way signal.

## Definition of done for a review
- Every **[block]** has a concrete reproduction or cited line.
- Scope matches description.
- I would be comfortable owning this code on-call.

<!-- TODO(personalize): tune the severity bar and the "things I always catch" list to
     YOUR taste — e.g. your stance on barrel files, test philosophy, CSS approach. -->
