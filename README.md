# Samplot Workflow

A Nextflow pipeline for visualizing structural variants using [samplot](https://github.com/ryanlayer/samplot).

## Overview

This workflow generates publication-quality visualizations of structural variants from BAM alignment files using samplot. It supports multiple samples, custom genomic regions, and various annotation overlays.

## Features

- **Multi-sample visualization**: Plot multiple BAM files in a single visualization
- **Flexible region selection**: Specify any genomic region by chromosome and coordinates
- **SV type support**: Visualize deletions, duplications, inversions, and other structural variants
- **Rich annotations**: Overlay transcript annotations and custom BED files
- **Customizable plots**: Adjust plot dimensions, depth, and quality thresholds

## Requirements

- Nextflow >= 23.10.0
- Docker or Singularity

## Quick Start

### 1. Prepare your samplesheet

Create a CSV file with your BAM files:

```csv
sample_name,alignment,index
sample1,s3://path/to/sample1.bam,s3://path/to/sample1.bam.bai
sample2,s3://path/to/sample2.bam,s3://path/to/sample2.bam.bai
```

### 2. Run the workflow

```bash
nextflow run main.nf \
  --input samplesheet.csv \
  --chrom chr2 \
  --start 110121338 \
  --end 110207020 \
  --sv_type DEL \
  --reference s3://path/to/reference.fasta
```

## Parameters

### Required Parameters

| Parameter | Description |
|-----------|-------------|
| `--input` | Path to samplesheet CSV file |
| `--chrom` | Chromosome to visualize (e.g., 'chr1', '1') |
| `--start` | Start position of the region |
| `--end` | End position of the region |
| `--sv_type` | Structural variant type (DEL, DUP, INV, etc.) |

### Optional Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `--reference` | Reference genome FASTA file | None |
| `--transcript_file` | Transcript annotation file (GTF/GFF) | None |
| `--transcript_file_index` | Transcript file index (.tbi) | None |
| `--annotation_files` | Space-separated BED files for annotation | None |
| `--annotation_files_index` | Space-separated index files (.tbi) | None |
| `--window` | Window size around the region | None |
| `--max_depth` | Maximum read depth to display | None |
| `--plot_height` | Plot height in pixels | None |
| `--plot_width` | Plot width in pixels | None |
| `--include_mqual` | Include mapping quality | None |
| `--output_file` | Custom output filename | Auto-generated |

## Input Format

### Samplesheet

The samplesheet must be a CSV file with the following columns:

- `sample_name`: Unique identifier for the sample
- `alignment`: Path to BAM file (local or S3)
- `index`: Path to BAM index file (.bai)

## Output

The workflow generates:
- PNG visualization of the specified region
- `versions.yml` file with software versions

## Example

```bash
nextflow run main.nf \
  --input samples.csv \
  --chrom chr21 \
  --start 10000000 \
  --end 10100000 \
  --sv_type DEL \
  --reference s3://bucket/reference.fasta \
  --transcript_file s3://bucket/transcripts.gff3.gz \
  --transcript_file_index s3://bucket/transcripts.gff3.gz.tbi \
  --annotation_files s3://bucket/genes.bed.gz \
  --annotation_files_index s3://bucket/genes.bed.gz.tbi \
  --window 1000 \
  --max_depth 500
```

## Configuration

The workflow uses configuration files in `samplot_wf/config/` to manage process resources and Docker containers.

## Credits

This workflow was developed for structural variant visualization in genomics research.

## License

MIT License

## Citation

If you use this workflow, please cite:
- [Samplot](https://github.com/ryanlayer/samplot)
- [Nextflow](https://www.nextflow.io/)

