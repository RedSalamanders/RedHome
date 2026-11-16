---
name: handoff-note
description: Synthesize multi-repository findings into durable RedHome wiki updates and a concise session handoff with exact commit, receipt, and gate provenance.
---

# Handoff Note

Adapted from Matt Pocock's `handoff` and Karpathy's LLM-Wiki workflow. Use this skill at the end of a complex cross-repo investigation, pin wave, or multi-stage session so architectural knowledge compounds in `RedHome/wiki/` instead of vanishing in chat logs.

## Iron Laws

1. Durable cross-project facts (gotchas, ABI invariants, shared build mechanics, glossary terms) go into the permanent topic pages under `RedHome/wiki/`—never as dated chat dumps in `wiki/`.
2. Never claim native qualification, ARM64 runtime pass, interactive-focus coverage, or CI completion from partial/scoped runs; distinguish `LOCALLY_VALIDATED`, `CI_PENDING`, cross-compile-only, and `HOSTED_ACCEPTED` states truthfully.

## Workflow

1. Extract any lasting cross-project architectural insights or terminology discovered during the session and fold them into the relevant `wiki/*.md` page (`Ecosystem-Architecture.md`, `Shared-Engineering-Policies.md`, `Glossary.md`, or a project dossier).
2. Run `pwsh -NoProfile -File ./validate.ps1` in `RedHome` if any `wiki/` file changed.
3. Produce a compact handoff summary containing:
   - **Touched Repositories & Branches**: Exact repo, branch, `HEAD` SHA, and clean/dirty state.
   - **Verified Evidence**: Exact commands run, build/test receipts produced, and configurations passed.
   - **Open Gates**: Remaining configurations (`Debug`, `Release`, `ASan Debug`, ARM64 builds, interactive focus, paired perf, or CI checks) and next ordered step.
