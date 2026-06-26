---
name: referee-report
description: >
  Turn a dictated/verbal manuscript-review transcript into a formal referee report delivered as
  Word documents. Produces two standalone .docx files (comments to the authors, comments to the
  editor) from the reviewer's spoken notes plus the manuscript PDFs, then iterates with the reviewer
  who edits the .docx directly. Use when the user has a transcript of a verbal paper review (or rough
  review notes) and wants a polished referee report as .docx, or asks to "write up my review,"
  "organize my dictated review," "make the reviewer Word doc," or "split the editor comments." Applies
  the house style and rigor checks below (no AI tells, verified numbers/citations, data-deposit check,
  provenance audit).
---

# Referee report from a verbal review

Convert a reviewer's dictated review + the manuscript into a formal, submission-ready referee report
as two Word documents, then collaborate as the reviewer edits in Word.

## Inputs

- **The transcript**: a dictation of the reviewer reading the paper and speaking comments with line
  numbers. It is messy (filler, mis-transcriptions of gene/tool names, restarts). It is the source of
  truth for *what the reviewer actually thinks*. Treat garbled names as phonetic (e.g. "Sturgatchis"
  = Stergachis, "Jacobin" = Dubocanin, "FGFR2" may be FCGR2C) and confirm against the manuscript.
- **The manuscript** (main PDF + supplement + extended data). Often line-numbered. Extract text with
  `pdftotext` (preserves the line numbers); read figure pages with the Read tool to get values printed
  inside figure panels.

## Deliverables

Two **standalone** `.docx` in the project directory:
- `*_comments_to_authors.docx` — the full section-by-section report.
- `*_comments_to_editor.docx` — short, 1–2 paragraphs, confidential.

Keep all intermediate markdown/text in the scratchpad/temp dir, not the project dir. Generate `.docx`
from markdown with `pandoc`.

The two documents must **not cross-reference each other**. No "see above," no "as noted to the editor."
Internal references *within* a document (e.g. "see Major point 2") are fine.

## Process

1. **Organize the transcript** into a structured review that mirrors the paper (Summary/overall,
   Major points, then section-by-section, then Minor points). Every point must trace to something the
   reviewer actually said (see Provenance audit).
2. **Verify before asserting** (numbers, citations, data — see Rigor). A referee report's catches are
   only as good as their facts.
3. **Write to house style** (see Voice & style).
4. **Generate both `.docx`** with pandoc; run the AI-writing detector; confirm zero em dashes.
5. **Iterate.** The reviewer edits the `.docx` in Word. Round-trip their edits before any regenerate
   (see Round-trip workflow).

## Voice & style

- **Never second person at the authors.** This is the one hard rule of address: no "you"/"your"
  ("You present…", "your figure"). Refer to them in the third person — either "the authors" or the
  authors' surname ("Yang et al.") is fine, whichever reads better. The reviewer speaks in first
  person ("I", "my concern"). Requests are imperative ("Please specify…", "Please report…").
- **Editor comments: short.** 1–2 paragraphs, standalone, third person: value of the work, then the
  recommendation and the few highest-order concerns. No section-by-section detail.
- **No AI tells.** Zero em dashes — use commas, parentheses, colons, or separate sentences. (En dashes
  in numeric ranges like 268–269 are fine.) Avoid hollow intensifiers ("genuinely", "truly"),
  editorial titles, and appeals to authority ("Per Nature policy…") — the request stands on its own.
  Ground prose in the `avoid-ai-writing` skill; aim for the detector's HUMAN_ONLY.
- **Brevity lens.** Don't do the authors' math or work for them. State the problem and that it needs
  fixing (e.g. "a base-level accuracy of 99.5% and QV69.2 are orders of magnitude apart and cannot
  describe the same quantity"), not the full derivation. Keep the specific evidence that *is* the
  finding (line numbers, figure refs, the one impossible number); cut everything re-derived for them.
- **Bullet lead-ins.** Bold a lead-in *only* when it is a specific location callout, and then only the
  location: **Lines 184 to 186.**, **Figure 1d.**, **Extended Data Fig. 4c/4d.**, **Methods, lines
  1103 to 1114.** No descriptive label after the numbers. Thematic points start in plain prose, no
  bold. Don't bold for emphasis. Exception: a top-level "Major points" list may keep short bold
  thematic titles, since they get cross-referenced as "Major point N".
- **Hold authors to the standard; no easy outs.** When a claim falls short of a community standard,
  require the standard, don't offer a rename. (E.g. T2T means both telomeres present, no internal or
  scaffold gaps, validated — not "single contig"; ask how many chromosomes actually meet it.)
- **Require operational definitions with reasoning**, not conceptual ones. If a category (e.g.
  "Indigenous") is defined only descriptively, ask for explicit inclusion criteria and the reasoning
  for each assignment.
- **Put the burden on the authors.** Require them to produce missing artifacts (e.g. a per-sample
  accession table); don't generate the artifact for them.

## Rigor (verify before it goes in the report)

- **Numbers.** Check every quantitative claim against the manuscript. `pdftotext` the main PDF and
  grep the figure; for values printed inside a figure panel, open that PDF page with Read and read the
  bar/label. The centerpiece "internally impossible" catches collapse if a source number is wrong.
- **Citations.** For every reference, confirm it is a real paper with the right journal/volume/pages
  AND that it actually supports the attributed claim. Web-verify against PubMed/journal. Drop any you
  cannot confirm — especially scientific/literature claims (e.g. introgression priors). If the
  reviewer asks "is X novel?", research it and supply the citations, but still verify each.
- **Data availability** (a reviewer responsibility). Run a subagent (or do it directly) to check the
  Data Availability statement and every accession/URL: does it resolve, and is it open / controlled /
  embargoed / dead? Are the core products (assemblies, graph, raw reads) deposited in a *recognized*
  archive (INSDC: ENA/NCBI/DDBJ, or NGDC GWH) with persistent accessions or a DOI — not just a lab
  website? Is there a Code/Software Availability statement? Report gaps as review points.
- **Provenance audit.** Every point in the formal report must trace to the transcript. After drafting,
  diff the report against the transcript and flag:
  - **AI-introduced** points (not in the transcript at all),
  - **AI-reframed** points (the reviewer's point altered),
  - **AI embellishments** (manuscript specifics the AI added on top of the reviewer's point).
  Present the flagged items to the reviewer and cut or get explicit approval before keeping. The report
  must reflect the reviewer's judgments, not model over-reach. (AI-introduced points can also misread
  the manuscript — verify the manuscript actually says what the point claims.)

## Round-trip workflow (the .docx is the source of truth)

Once the reviewer starts editing in Word, the `.docx` is canonical; your scratchpad markdown goes
stale immediately. Before applying any further change:

1. `pandoc <docx> -t markdown --wrap=none -o current.md` (unwrapped = one line per bullet, easy to
   edit and diff).
2. Diff `current.md` against your scratchpad source to capture the reviewer's manual edits.
3. Merge their edits in, then apply the new change, then regenerate the `.docx`.

Never blind-overwrite the `.docx` from a stale copy. Watch for **concurrent editing**: if Word has the
file open, a Word save can clobber your regenerate (and vice versa) — tell the reviewer to save, then
reload, and re-sync if needed. When the reviewer asks for *new text only*, give it in a fenced code
box and do **not** integrate it into the doc unless asked.

## Tooling

- `pandoc` — markdown → docx, and docx → markdown (`--wrap=none`).
- AI-writing detector: `node ~/.claude/skills/avoid-ai-writing/detector/patterns.js` via
  `AIDetector.analyzeText(text)`; target `HUMAN_ONLY`. Also run the `avoid-ai-writing` skill on prose.
- `pdftotext` for manuscript text (keeps line numbers); Read tool for figure-panel values.
- Subagent (Agent tool) for the data-deposition check; have it report, don't have it edit files.

## Quick checks before handing back

```bash
# zero em dashes in the generated docx
unzip -p out.docx word/document.xml | grep -c "—"        # must be 0
# no second-person address to the authors (the one hard rule)
unzip -p out.docx word/document.xml | grep -ciE ">[^<]*\b(you|your)\b"   # must be 0
# detector
node -e 'const D=require(process.env.HOME+"/.claude/skills/avoid-ai-writing/detector/patterns.js");const fs=require("fs");console.log(D.analyzeText(fs.readFileSync("source.md","utf8")).document_classification)'
```
