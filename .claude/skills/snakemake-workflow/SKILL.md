---
name: snakemake-workflow
description: >
  Scaffold and extend Snakemake workflows the Vollger Lab way, following the SmkTemplate
  (https://github.com/vollgerlab/SmkTemplate) conventions: pixi-managed environment, the
  workflow/ layout, a SLURM executor profile, and apptainer+conda software deployment. Use
  when asked to start a new Snakemake pipeline, add or refactor rules, set up a workflow repo,
  wire up the SLURM profile, or work in a repo that already uses this structure. Bundles the
  template files under templates/ and the canonical run/lint commands.
---

# Snakemake workflow (Vollger Lab / SmkTemplate)

Build Snakemake pipelines that match the lab template. Canonical source:
`https://github.com/vollgerlab/SmkTemplate`. The fastest way to start a real project is to make
a repo from the template, not to hand-copy files:

```bash
gh repo create <name> --template vollgerlab/SmkTemplate --private --clone
cd <name> && pixi install
```

Use the bundled `templates/` here when you need to scaffold inside an existing repo, understand
the conventions, or work offline.

## Layout

```
config/config.yaml                  # user-facing config (sample sheet, params)
workflow/Snakefile                  # entrypoint: min_version, include rules, rule all
workflow/rules/common.smk           # helpers (resource fns, input fns, wildcard constraints)
workflow/scripts/                   # python/R scripts called by rules (add as needed)
workflow/envs/env.yml               # per-rule conda env(s)
workflow/profiles/default/config.yaml  # execution profile (cores, deployment, slurm, logger)
pixi.toml                           # pins snakemake + dev tools, defines run/fmt tasks
```

## Conventions

- **Environment is pixi.** Snakemake is pinned in `pixi.toml` (e.g. `snakemake ==9.17.1`). Never
  `pip install` snakemake into another env. Channels: `conda-forge`, `bioconda`.
- **Run through pixi**, which sets the right Snakefile and respects `$INIT_CWD`:
  - `pixi run snakemake ...` (the task does `cd $INIT_CWD && snakemake -s $PIXI_PROJECT_ROOT/workflow/Snakefile`)
  - From another directory: `pixi run --manifest-path /path/to/pixi.toml snakemake ...`
- **Always dry run first:** `pixi run snakemake -n` (or `-np` to print shell commands).
- **`rule all`** lists explicit expected outputs. Keep target lists in `common.smk` when they grow.
- **Resources scale with retries.** Use the `get_mem_mb(wildcards, attempt)` helper and
  `restart-times` so transient OOMs recover. Parameterize `threads:` and `resources:`; never hardcode.
- **Intermediates use `temp()`**; large I/O goes to `/scratch`, not `/home`. Prefer softlinks over
  copying large genomic files, and keep index files (`.bai/.csi/.tbi/.fai`) beside their data.
- **Software deployment** is apptainer + conda (set in the profile). Define a conda env per rule via
  `conda: "envs/env.yml"` (or a rule-specific env) when possible; containers preferred on HPC.
- **SLURM:** the `snakemake-executor-plugin-slurm` is a dependency. Run on the cluster by adding the
  slurm profile / `--executor slurm`. The default profile uses `logger: snkmt` for nicer logs.
- **Format before committing:** `pixi run fmt` (runs `snakefmt workflow/`, `ruff format .`,
  `taplo format pixi.toml`). Scripts in `workflow/scripts/` are Python with type hints, f-strings,
  pathlib, argparse; prefer streaming over loading whole BAM/FASTA into memory.

## Don't

- Don't `rm -rf` snakemake output dirs to force a rerun. Use `--forcerun <rule>`, `-R <rule>`,
  `--forceall`, or `--rerun-incomplete` and let snakemake manage its own state.
- Don't hardcode reference paths or data paths; parameterize via `config/config.yaml` and wildcards.
- Don't commit `results/`, `temp/`, `logs/`, `.snakemake/`, `.pixi/` (see template `.gitignore`).

## Killing a stuck run

`kill -INT $pid` hangs because snakemake's `pool.shutdown()` waits on child processes (minimap2,
etc.) that never get the signal. Signal the whole process group instead:

```bash
kill -INT -- -$(ps -o pgid= -p $(pgrep -f 'bin/snakemake .*-s' | head -1) | tr -d ' ')
```

## Adding a rule (pattern)

```python
rule align:
    input:
        ref=config["ref"],
        reads="results/{sample}/reads.fq.gz",
    output:
        bam=temp("results/{sample}/aln.bam"),
    threads: 8
    resources:
        mem_mb=get_mem_mb,
    conda:
        "envs/env.yml"
    shell:
        "minimap2 -t {threads} -ax map-hifi {input.ref} {input.reads} "
        "| samtools sort -@ {threads} -o {output.bam}"
```
