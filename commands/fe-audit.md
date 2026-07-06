---
description: Quick accessibility + performance (Core Web Vitals) audit of the current frontend project. Reports findings by severity with concrete fixes.
argument-hint: "[path or component to focus on — optional]"
---

# /fe-audit

Run a fast, pragmatic **accessibility + performance** pass over the frontend and
report findings by severity. Scope: `$ARGUMENTS` if given, otherwise the whole app
(prioritize routes/components most visited).

This is a heuristic static + build-time audit — not a substitute for a full Lighthouse
run or real-device testing, but enough to catch the recurring offenders quickly.

## Accessibility
- Semantic HTML: `div`/`span` used where `button`, `a`, `nav`, `main`, `label`,
  headings belong. Interactive `div`s with `onClick` and no keyboard handler.
- Keyboard: focusable order, visible focus styles, focus trap/return on modals & route
  changes, no positive `tabindex`.
- Labels & names: inputs with associated labels, icon-only buttons with accessible
  names, images with meaningful `alt` (or `alt=""` when decorative).
- Contrast & zoom: obvious low-contrast text, layouts that break at 200% zoom.
- ARIA sanity: no redundant/incorrect ARIA that overrides native semantics.

## Performance (Core Web Vitals lens)
- **LCP**: hero image priority/preload, blocking fonts, oversized above-the-fold images.
- **INP/responsiveness**: heavy synchronous work in event handlers, unmemoized
  expensive renders, large lists without virtualization.
- **CLS**: images/embeds without dimensions, late-injected banners, font swap shifts.
- **Bundle**: check `build` output / analyzer if available — large deps, missing code
  splitting on routes, barrel imports pulling in whole libraries, unoptimized images.

## Report format
For each finding:
```
[block|should|nit] <area> — <file:line or component>
  Problem: <concrete, one line>
  Fix: <specific change>
```
End with a **top-3 highest-impact fixes** list. If a check can't be verified
statically, say so rather than guessing.

<!-- TODO(personalize): add the perf budgets and a11y bar YOUR teams hold to
     (e.g. LCP < 2.5s, bundle < Xkb, WCAG AA). -->
