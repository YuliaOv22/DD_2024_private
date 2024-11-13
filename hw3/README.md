# Snakemake Pipeline for Genome Assembly and Annotation 

This repository contains a Snakemake pipeline for genome assembly and annotation. The pipeline includes steps for quality control, genome assembly, quality assessment, and annotation. Below, you will find detailed instructions on how to set up and run the pipeline, as well as information on the input and output files.

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

- Python 3.x
- Snakemake 8.x
- Conda (for managing environments)
- FastQC
- SPAdes
- QUAST
- Prokka
- Blast=2.9.0
- Abricate

## Installation
[3]: Installation

--bash

**Clone the repository:**
```
git clone https://github.com/yourusername/bioinformatics-pipeline.git
cd bioinformatics-pipeline
```

**Set up the Conda environment:**
```
conda env create -f environment.yaml
conda activate bioinformatics-pipeline
```

## Configuration
[4]: Configuration

The pipeline uses a params.json file to configure parameters such as output directories and tool-specific settings. Below is an example of the params.json file:

--json
```
{
    "fastqc_out": "test_output/fastqc",
    "spades_out": "test_output/spades",
    "quast_out": "test_output/quast",
    "prokka_out": "test_output/prokka",
    "abricate_out": "test_output/abricate",
    "databases": ["ncbi", "resfinder", "vfdb"],
    "fastqc_params": {
        "threads": 4
    },
    "spades_params": {
        "threads": 8
    },
    "quast_params": {
        "threads": 4
    },
    "prokka_params": {
        "kingdom": "Bacteria",
        "genus": "Escherichia",
        "species": "coli"
    },
    "abricate_params": {
        "threads": 4
    }
}
```

## Running the Pipeline
[5]: Running_the_Pipeline
To run the pipeline, use the following command:

--bash
```
snakemake --use-conda -j 4
```
This command will execute the pipeline using 4 cores and will automatically create and use the Conda environments specified in the Snakefile.

## Input Files
[6]: Input_Files

The pipeline expects paired-end FASTQ files in the test_input directory. The filenames should follow the pattern {sample}_1.fastq.gz and {sample}_2.fastq.gz.
In addition input files can contain assambly with the pattern {sample}_scaffolds.fasta.
Samples is read from the file sample.csv.

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
1,SRR31122807_1.fastq.gz,SRR31122807_2.fastq.gz
2,SRR31305919_1.fastq.gz,SRR31305919_2.fastq.gz,SRR31305919_scaffolds.fasta
```

Download reads you can on the website of [**National Library of Medicine**](https://www.ncbi.nlm.nih.gov/sra/docs/sradownload/)

--conda
```
conda install -c bioconda -c conda-forge sra-tools
prefetch SRR31122807
fastq-dump --split-files --gzip SRR31122807.sra
```

## Output Files
[7]: Output_Files

The pipeline generates the following output files:

- FastQC: Quality control reports in HTML and ZIP formats.
- SPAdes: Assembled scaffolds and contigs in FASTA format.
- QUAST: Quality assessment report in various types format.
- Prokka: Genome annotation in various types format.
- Abricate: Annotation analysis reports in TAB format (can be customized).


## Troubleshooting
[8]: Troubleshooting

If you encounter any issues while running the pipeline, please check the following:

**Input Files**: Ensure that the input FASTQ files are correctly named and placed in the test_input directory.

**Permissions**: Ensure that you have the necessary permissions to read and write files in the working directory.

**Dependencies**: Ensure that all required tools are installed and available in the Conda environment.

**Warning** Support for alternative conda frontends has been deprecated in favor of simpler support and code base. This should not cause issues since current conda releases rely on fast solving via libmamba. Ignoring the alternative conda frontend setting (mamba).

## License
[9]: License
This project is licensed under the MIT License. See the LICENSE file for details.

Feel free to contribute to this project by submitting issues or pull requests. Happy bioinformatics!
