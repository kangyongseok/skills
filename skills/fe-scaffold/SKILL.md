---
name: fe-scaffold
description: Scaffold a new frontend component or feature using my personal conventions — folder colocation, naming, tests, and states. Use when creating a new component, hook, or feature slice. Encodes my structure preferences so new code looks consistent across any codebase.
---

# fe-scaffold

Generate a new component/feature that matches **my conventions**, adapted to the
host repo's stack. Detect the stack first, then scaffold — never impose a framework
the repo doesn't use.

## Step 0: detect, don't assume
Read `package.json` and existing sibling files to infer: framework (React/Next/Vue/
Svelte), language (TS/JS), styling (CSS Modules / Tailwind / styled / vanilla-extract),
test runner (Vitest/Jest + Testing Library), and the folder convention already in use.
**Match the repo.** If it conflicts with my defaults below, the repo wins.

## My conventions (defaults — repo overrides)
- **Colocation.** One folder per component, everything it owns lives beside it:
  ```
  ComponentName/
    ComponentName.tsx        # implementation
    ComponentName.test.tsx   # behavior tests
    index.ts                 # re-export (clean import path)
    ComponentName.module.css # styles (if CSS Modules)
  ```
  Hooks and helpers used only by this component stay in the folder until a second
  consumer appears — then promote. Avoid premature shared/ dumping grounds.
- **Naming.** PascalCase components & files, `useX` for hooks, `handleX` for event
  handlers, boolean props read as assertions (`isOpen`, `hasError`).
- **Props.** Explicit typed props; no prop explosion — if a component takes >6 props
  or drills them through, reconsider composition or context.
- **States built-in.** Every data-driven component ships loading / empty / error
  paths from the start, not as a follow-up.
- **A test that means something.** One test that exercises the primary user behavior,
  not a snapshot of the DOM.

## Output
Create the folder + files, wire the re-export, and print the import path the author
should use. Do not touch unrelated files or global config.

<!-- TODO(personalize): replace the defaults above with YOUR actual conventions —
     styling library, test style, whether you use barrel files, story files, etc. -->
