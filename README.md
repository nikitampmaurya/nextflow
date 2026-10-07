# GATK Variant Calling Pipeline with Nextflow

## Aim:

To build a reproducible **Nextflow-based variant calling pipeline** using GATK and Samtools.

## Pipeline overview

The pipeline takes aligned BAM files as input and performs the following steps:

```text
BAM files
   │
   ▼
Samtools Index
   │
   ▼
BAM + BAI
   │
   ▼
GATK HaplotypeCaller
   │
   ▼
Per-sample GVCFs
   │
   ▼
GenomicsDBImport
   │
   ▼
GenomicsDB
   │
   ▼
GenotypeGVCFs
   │
   ▼
Cohort-level VCF
```

## Tools used

- **Nextflow** – workflow management and pipeline orchestration
- **Samtools** – BAM indexing
- **GATK HaplotypeCaller** – per-sample variant calling in GVCF mode
- **GATK GenomicsDBImport** – imports multiple GVCFs into a GenomicsDB datastore
- **GATK GenotypeGVCFs** – joint genotyping across the cohort
- **Docker** – provides the software environments used by the pipeline

## Pipeline structure

```text
.
├── genomics.nf
├── nextflow.config
├── modules/
│   ├── samtools_index.nf
│   ├── gatk_haplotypecaller.nf
│   └── gatk_jointgenotyping.nf
```

### `genomics.nf`

The main workflow file. It:

1. Reads the input samplesheet.
2. Creates a channel containing the BAM files.
3. Runs BAM indexing.
4. Runs GATK HaplotypeCaller for each sample.
5. Collects the per-sample GVCFs.
6. Runs joint genotyping.
7. Publishes the pipeline outputs.

### `modules/samtools_index.nf`

Creates a BAM index (`.bai`) for each input BAM file.

### `modules/gatk_haplotypecaller.nf`

Runs GATK HaplotypeCaller in GVCF mode:

```bash
-ERC GVCF
```

This produces a GVCF for each sample for use in the joint genotyping step.

### `modules/gatk_jointgenotyping.nf`

Performs two steps:

1. `GenomicsDBImport` – imports the per-sample GVCFs into a GenomicsDB datastore.
2. `GenotypeGVCFs` – performs joint genotyping and produces a cohort-level VCF.

### `nextflow.config`

Contains the test profile and paths to the input samplesheet, reference files, interval file and cohort name.

## Reference files

| File | Purpose |
|---|---|
| `ref.fasta` | Reference genome sequence |
| `ref.fasta.fai` | FASTA index for efficient access to the reference |
| `ref.dict` | GATK sequence dictionary containing contig information |
| `intervals.bed` | Genomic regions to analyse |

## Data

The input data and reference files used in this project were provided by the **Nextflow for Genomics training course**.

## Input

The test pipeline uses a CSV samplesheet containing the BAM file paths.

Example:

```text
sample,reads_bam
sample1,data/sample1.bam
sample2,data/sample2.bam
sample3,data/sample3.bam
```

## Running the test pipeline

Run the pipeline using the `test` profile:

```bash
nextflow run genomics.nf -profile test
```

Docker must be enabled because the pipeline uses Docker containers for Samtools and GATK.

## Expected outputs

The pipeline produces:

```text
indexed_bam/
    sample1.bam
    sample1.bam.bai
    ...

gvcf/
    sample1.bam.g.vcf
    sample1.bam.g.vcf.idx
    ...

family_trio.joint.vcf
family_trio.joint.vcf.idx
```

The final `family_trio.joint.vcf` contains the **cohort-level jointly genotyped variant calls**.

## Learning objectives

This project was created to practise:

- Building a modular Nextflow pipeline
- Creating and using Nextflow channels
- Passing files between processes
- Using tuples to keep related files together
- Using `.collect()` to gather per-sample outputs for cohort-level analysis
- Using Docker containers in Nextflow
- Understanding the GATK GVCF and joint genotyping workflow
- Organising a bioinformatics pipeline into reusable modules

## Notes

This is a **training/learning pipeline** and has not been developed or validated as a production or clinical variant-calling workflow.
