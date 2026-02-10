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

## Tech Stack

- **Languages**: Rust (Primary), R, python, Bash
- **Workflows**: Snakemake (preferred pipeline manager)
- **Data formats**: BAM/CRAM, VCF/BCF, BED, FASTA/FASTQ, Arrow/Parquet for tabular data
- **Key tools**: minimap2, hifiasm, samtools, bedtools, fibertools (`ft`)
- **Visualization**: ggplot2
- **Version control**: Git + GitHub

## Coding Conventions

- Python: use type hints, f-strings, pathlib over os.path. Prefer polars over pandas for dataframes.
- Bash: start every script with `#!/usr/bin/env bash` and `set -euo pipefail`
- Snakemake: use `rule all` with explicit expected outputs. Define conda envs per rule when possible.
- Write docstrings for public functions.

## Common Commands

I like to use pixi for python environment management and snakemake for workflow management. Here are some common commands:

```bash
pixi install
pixi add pysam samtools
pixi run snakemake ...
```

## Important Patterns

- Prefer softlinks over copying large genomic data files.
- For large file I/O, use `/scratch` not `/home`.
- Reference genome paths should be parameterized, not hardcoded.

## Don't

- Don't hardcode absolute paths to data files in scripts — use config files or Snakemake wildcards.
- Don't `pip install` into the base conda environment.
- Don't use `os.system()` — use `subprocess.run()` with `check=True`.
