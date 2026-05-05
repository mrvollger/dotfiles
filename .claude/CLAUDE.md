# CLAUDE.md

## Project Overview

Computational genomics lab (Vollger Lab, University of Utah, Dept. of Human Genetics).
Focus: long-read sequencing, segmental duplications, genome assembly, epigenomics (fiberseq/m6A), and variant effect prediction in complex genomic regions.

## Environment

- **Cluster**: CHPC Redwood (`redwood15.chpc.utah.edu`)
- **Scheduler**: SLURM
- **Lab shared bin**: `/scratch/ucgd/lustre-labs/vollger/bin`
- **Projects dir**: `/scratch/ucgd/lustre-labs/vollger/projects`
- **Conda**: prefer `mamba` for environment management
- **Containers**: Apptainer/Singularity preferred for reproducibility on HPC
- **Compression**: prefer `bgzip` over `gzip`/`gunzip` — it supports multithreading (`-@ threads`) and indexing with `tabix`. On macOS, `zcat` is broken — use `bgzip -dc` or `gunzip -c` instead.
  - Compress: `bgzip -@ 4 file.vcf` (produces `file.vcf.gz`)
  - Decompress: `bgzip -d file.vcf.gz` (or `bgzip -dc` to write to stdout)
  - Keep original: `bgzip -dk file.vcf.gz`

## Tech Stack

- **Languages**: Rust (primary), R, Python, Bash
- **Workflows**: Snakemake (preferred pipeline manager)
- **Data formats**: BAM/CRAM, VCF/BCF, BED, FASTA/FASTQ, Arrow/Parquet for tabular data
- **Key tools**: minimap2, hifiasm, samtools, bedtools, fibertools (`ft`)
- **Visualization**: ggplot2 (R), plotly/matplotlib (Python)
- **Testing**: `cargo test` (Rust), `pytest` (Python)
- **Version control**: Git + GitHub

## Coding Conventions

- **Python**: type hints, f-strings, `pathlib` over `os.path`. Prefer polars over pandas. Use context managers for file I/O.
- **Rust**: use `Result<T, E>` for fallible operations. Prefer streaming/iterative processing over loading entire files into memory. Document unsafe blocks. Always run cargo fmt, clippy, and tests before committing.
- **Bash**: start every script with `#!/usr/bin/env bash` and `set -euo pipefail`.
- **Snakemake**: use `rule all` with explicit expected outputs. Define conda envs per rule when possible. Use `temp()` for intermediate files. Parameterize threads and memory via `resources:`.
- **Docstrings**: write docstrings for public functions. NumPy-style for Python, rustdoc for Rust.

## Common Commands

```bash
# Environment management
pixi install
pixi add pysam samtools

# Workflow execution
pixi run snakemake --profile profiles/slurm ...
snakemake -n  # dry run first

# Data validation
samtools quickcheck *.bam
bcftools stats input.vcf.gz
```

## Important Patterns

- Prefer softlinks over copying large genomic data files.
- For large file I/O, use `/scratch` not `/home`.
- Reference genome paths should be parameterized, not hardcoded.
- Always move index files alongside their BAM/CRAM/VCF files.
- Use streaming pipelines for large BAM processing — don't load entire files into memory.
- Validate downloaded reference files with checksums.

## Don't

- Don't hardcode absolute paths to data files — use config files or Snakemake wildcards.
- Don't `pip install` into python envs managed by other tools, pixi, uv, ect.
- Don't commit large output or data files — use `.gitignore`.
- Don't forget index files when moving/symlinking BAM/CRAM/VCF files.
- Don't `rm -rf` snakemake output dirs to force re-runs. Use `--forcerun <rule>`, `-R <rule>`, `--forceall`, or `--rerun-incomplete` and let snakemake manage its own state.

## Git Conventions

- Write concise commit messages that explain *why*, not just *what*.
- Use feature branches for non-trivial changes.

## Writing notes
- Avoid the use of — em dashes — in favor of commas or parentheses for clarity. Just limit their use to avoid looking like AI.
