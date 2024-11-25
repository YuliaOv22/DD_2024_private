# Nextflow Pipeline for Genome Assembly and Annotation 

This repository contains a Nextflow pipeline for genome assembly and annotation. The pipeline includes steps for quality control, genome assembly, quality assessment, and annotation. Below, you will find detailed instructions on how to set up and run the pipeline, as well as information on the input and output files.

Table of Contents
- [Overview][1]
- [Requirements][2]
- [Installation][3]
- [Configuration][4]
- [Running the Pipeline][5]
- [Input Files][6]
- [Output Files][7]
- [Troubleshooting][8]
- [License][9]

## Overview
[1]: Overview

The pipeline consists of the following steps:

1. Quality Control (FastQC): Assesses the quality of raw sequencing reads.
2. Genome Assembly (SPAdes): Assembles the genome from paired-end reads.
3. Quality Assessment (QUAST): Evaluates the quality of the assembled genome.
4. Genome Annotation (Prokka): Annotates the assembled genome.
5. Annotation Analysis (Abricate): Analyzes the annotated genome for antimicrobial resistance genes.

## Requirements
[2]: Requirements

### Requirements

- Python 3.x
- Nextflow 24.x
- Bash
- Java 11 (or later, up to 21)
- Git
- Docker

### Optional requirements

- Conda 4.5 (or later)

## Installation
[3]: Installation

--bash

**Clone the repository:**
```
git clone
```

**Set up the Conda environment:**
```
conda env create -n nextflow -c bioconda -c conda-forge nextflow
conda activate nextflow
```

## Configuration
[4]: Configuration

The pipeline uses a `nextflow.config` file to configure parameters such as output directories and tool-specific settings. Below is an example:

--config
```
params {
    indir = "${projectDir}/test_input/"
    outdir = "${projectDir}/test_output/"
    parse_csv = "${projectDir}/samples.csv"
    databases = ["ncbi", "refinder", "vfdb"]
    
    paths = [
        fastqc: { sid -> "${params.outdir}/fastqc/${sid}" },
        spades: { sid -> "${params.outdir}/spades/${sid}" },
        quast:  { sid -> "${params.outdir}/quast/${sid}" },
        prokka:  { sid -> "${params.outdir}/prokka/${sid}" },
        abricate:  { sid -> "${params.outdir}/abricate/${sid}" },
    ]
}
```

## Running the Pipeline
[5]: Running_the_Pipeline
To run the pipeline, use the following command:

--bash
```
cd <repo name>/hw4 && nextflow run main.nf --with-docker
```
This command will execute the pipeline will run the pipe with using Docker containers.
You may not write ```--with-docker``` because, it was written in `nextflow.config`.

## Input Files
[6]: Input_Files

The pipeline expects paired-end FASTQ files in the test_input directory. The filenames should follow the pattern `{sample}_1.fastq.gz` and `{sample}_2.fastq.gz`.
In addition input files can contain assambly with the pattern `{sample}_scaffolds.fasta`.
Samples is read from the file `sample.csv`.

Examples:

```
test_input/
├── SRR31122807_1.fastq.gz
├── SRR31122807_2.fastq.gz
├── SRR31305919_1.fastq.gz
├── SRR31305919_2.fastq.gz
└── SRR31305919_scaffolds.fasta
```

Below is an example of the sample.csv file:

--csv
```
sample_id,reads,assembly
SRR31122807,[SRR31122807_1.fastq.gz,SRR31122807_2.fastq.gz],
SRR31305919,[SRR31305919_1.fastq.gz,SRR31305919_2.fastq.gz],SRR31305919_scaffolds.fasta
```

You can download reads on the website of [**National Library of Medicine**](https://www.ncbi.nlm.nih.gov/sra/docs/sradownload/)

--conda
```
conda install -c bioconda -c conda-forge sra-tools
prefetch SRR31122807
fastq-dump --split-files --gzip SRR31122807.sra
```

## Output Files
[7]: Output_Files

The pipeline generates the following output files:

- FastQC: Quality control reports in `.html` and `.zip` formats.
- SPAdes: Assembled scaffolds and contigs in `.fasta` format.
- QUAST: Quality assessment report in `.txt` format (can be customized).
- Prokka: Genome annotation in `.gff` format (can be customized).
- Abricate: Annotation analysis reports in `.tab` format (can be customized).


## Troubleshooting
[8]: Troubleshooting

If you encounter any issues while running the pipeline, please check the following:

**Input Files**: Ensure that the input `.fasta` files are correctly named and placed in the test_input directory.

**Permissions**: Ensure that you have the necessary permissions to read and write files in the working directory.

**Dependencies**: Ensure that all required tools are installed and available in the Conda environment.

**Docker**: Ensure that the Docker daemon is running. If you use Desktop Docker in Windows and WSL, check `Resources - Integration WSL`, Ubuntu-xx.xx must be turn on.

## License
[9]: License
This project is licensed under the MIT License. See the LICENSE file for details.

Feel free to contribute to this project by submitting issues or pull requests. Happy bioinformatics!
