---
name: mrv-grant-writing
description: Draft and revise Mitchell Vollger's grant proposals (research statements, specific aims, personal statements) the way he works them. Use when asked to write, retailor, restructure, review, or score a grant or fellowship proposal (Pew, Searle, NIH, CGM pilots, foundation awards), or to compare proposal versions. Captures his process (research the funder, plan, draft, adversarial subagent review, iterate by version), his voice rules, his science-integrity rules, and the practice of benchmarking against his strongest prior proposal.
metadata:
  author: Mitchell Vollger
  type: personal
---

# MRV grant writing

How Mitchell drafts and revises grant proposals. Distilled from his Pew, Searle, and CGM sessions into durable preferences that apply to any proposal. Follow the process and voice rules; do not invent a new style.

## When to use
Writing, retailoring, restructuring, reviewing, or scoring any grant or fellowship proposal, or comparing proposal versions. Also covers cover emails and personal/biosketch statements tied to a grant.

## How he works (the loop)
1. **Research first.** Before restructuring, research the specific program and recent funded proposals, then come back with a concrete plan for how to restructure. Do not jump to prose.
2. **Plan, then draft.** When asked for new text, make a real plan and state it before writing.
3. **He edits the doc; you suggest in chat.** Default: deliver suggestions and revised text in chat with the changes **bolded**, not a silent full rewrite. He pulls what he wants into the doc himself. Build a new file version only when he asks.
4. **Never overwrite his manual edits.** He edits in parallel. Before regenerating a version, pull his latest edits in; do not clobber them.
5. **Version everything.** Drafts are v1, v2, v3... Keep them all; he compares across versions and asks for earlier ones back.
6. **Self-check before showing.** Proofread twice, or review the result against the plan a few times, silently, then show him.
7. **Adversarial review by subagents.** Spawn ~3 reviewer subagents, give them web access to learn what the program rewards, have them score the draft and find weaknesses. Use this to compare versions and decide which is stronger. For a long unattended pass: iterate yourself plus three subagent reviewers for N rounds, then deliver one updated doc.

## Benchmark against his strongest prior proposal
He keeps a gold-standard proposal and judges new drafts against it (currently his Pew Biomedical Scholars research statement; new proposals often start as a retailoring of it). When a draft feels off, read the benchmark and compare directly. He wants blunt comparison and will say a new version is "significantly worse" if it is. Match the benchmark's language quality and logical build; do not drift from it while "improving" structure.

## Voice and style
Author rules: **no em dashes, no "not just X but Y", no rule-of-three padding, plain words, active voice.** Voice: technical and blunt. (Consistent with his global writing instructions.)
- Run the `avoid-ai-writing` skill on drafted prose. Aims especially must not sound fake or AI-ish.
- Kill clichés.
- **Logic must build across the whole document,** not just within paragraphs. A draft where the pieces are there but it "doesn't follow naturally" is not done. Each paragraph should depend on the one before.
- **Closing sentences carry weight,** especially the last line of a positioning paragraph. Offer several options when asked.

## Science integrity (where most drafts fail him)
- **Do not soften or hedge his scientific claims to sound safer.** If he states a number, a scope, or a thesis, keep it as stated; he will correct you if you shrink it. This is his single most common complaint.
- **Do not trade scientific accuracy for less jargon.** Reduce jargon, but if a simplification drops precision, show alternatives instead of shipping it.
- **Lead with the motivating result, then the confirmatory one.** Put the data that drives the argument first and the supporting data second.
- **Frame impact as field-wide, not lab-local.** Where his tools or methods are used by a whole field, make that land.
- **Build "why me" from his real track record,** stated plainly: he created the methods, and the field is only now able to do the work.

His standard track-record citations (reusable across his grants):
- SDs in the first gapless (T2T) human genome, >150 genes missing or misassembled in prior references: Vollger et al., **Science, 2022.**
- Elevated mutation and gene conversion reshaping duplicated genes: Vollger et al., **Nature, 2023.**
- fibertools: **Genome Research, 2024.**
- FIRE (Fiber-seq Inferred Regulatory Elements): **Cell, 2026, accepted in principle** (latest content on bioRxiv, including somatic epimutation).
- Functional sequencing for rare-disease diagnosis: **Nature Genetics, 2025.**

## Output mechanics
- **To fit more text:** small fonts, tight margins, and drop figures. Text-only, he can fit nearly as much as the benchmark. Use when space is the constraint.
- Run a formatting/length check against the program's limits when asked.
- **`.docx` reliability:** programmatic docx generation has produced files Word could not open. Verify a generated file opens, and offer to drop a working copy in Downloads or Desktop. If a generator keeps producing broken files, switch approach.

## Reference
- Benchmark (Pew): `~/Library/CloudStorage/OneDrive-UniversityofUtah/vollgerlab/Grants/2026-pew-internal/`
- Searle: `~/Library/CloudStorage/OneDrive-UniversityofUtah/vollgerlab/Grants/2026-Searle-Scholars-limited-submission-competition/`
- CGM = Utah Center for Genomic Medicine (institution and patient cohort). "CMG" in older notes was a typo for it.
