Bioinformatics Pipeline for Genome Assembly and Annotation
This repository contains a Snakemake pipeline for genome assembly and annotation. The pipeline includes steps for quality control, genome assembly, quality assessment, and annotation. Below, you will find detailed instructions on how to set up and run the pipeline, as well as information on the input and output files.

Table of Contents
Overview

Requirements

Installation

Configuration

Running the Pipeline

Input Files

Output Files

Customization

Examples

Troubleshooting

License

Overview
The pipeline consists of the following steps:

Quality Control (FastQC): Assesses the quality of raw sequencing reads.

Genome Assembly (SPAdes): Assembles the genome from paired-end reads.

Quality Assessment (QUAST): Evaluates the quality of the assembled genome.

Genome Annotation (Prokka): Annotates the assembled genome.

Annotation Analysis (Abricate): Analyzes the annotated genome for antimicrobial resistance genes.

Requirements
Python 3.x

Snakemake

Conda (for managing environments)

FastQC

SPAdes

QUAST

Prokka

Abricate

Installation
Clone the repository:

bash
Copy
git clone https://github.com/yourusername/bioinformatics-pipeline.git
cd bioinformatics-pipeline
Set up the Conda environment:

bash
Copy
conda env create -f environment.yaml
conda activate bioinformatics-pipeline
Configuration
The pipeline uses a params.json file to configure parameters such as output directories and tool-specific settings. Below is an example of the params.json file:

json
Copy
{
    "fastqc_out": "test_output/fastqc",
    "spades_out": "test_output/spades",
    "quast_out": "test_output/quast",
    "prokka_out": "test_output/prokka",
    "abricate_out": "test_output/abricate",
    "databases": ["ncbi", "resfinder", "vfdb"],
    "fastqc_params": {
        "threads": 4,
        "memory": "8G"
    },
    "spades_params": {
        "threads": 8,
        "memory": "16G"
    },
    "quast_params": {
        "threads": 4,
        "memory": "8G"
    },
    "prokka_params": {
        "kingdom": "Bacteria",
        "genus": "Escherichia",
        "species": "coli"
    },
    "abricate_params": {
        "threads": 4,
        "memory": "8G"
    }
}
Running the Pipeline
To run the pipeline, use the following command:

bash
Copy
snakemake --use-conda --cores 8
This command will execute the pipeline using 8 cores and will automatically create and use the Conda environments specified in the Snakefile.

Input Files
The pipeline expects paired-end FASTQ files in the test_input directory. The filenames should follow the pattern {sample}_1.fastq.gz and {sample}_2.fastq.gz.

Example:

Copy
test_input/
├── SRR31122807_1.fastq.gz
├── SRR31122807_2.fastq.gz
├── SRR31305919_1.fastq.gz
└── SRR31305919_2.fastq.gz
Output Files
The pipeline generates the following output files:

FastQC: Quality control reports in HTML and ZIP formats.

SPAdes: Assembled scaffolds and contigs in FASTA format.

QUAST: Quality assessment report in TXT format.

Prokka: Genome annotation in GFF format.

Abricate: Annotation analysis reports in TAB format.

Example output directory structure:

Copy
test_output/
├── fastqc/
│   ├── SRR31122807_1_fastqc.html
│   ├── SRR31122807_1_fastqc.zip
│   ├── SRR31122807_2_fastqc.html
│   ├── SRR31122807_2_fastqc.zip
│   ├── SRR31305919_1_fastqc.html
│   ├── SRR31305919_1_fastqc.zip
│   ├── SRR31305919_2_fastqc.html
│   └── SRR31305919_2_fastqc.zip
├── spades/
│   ├── SRR31122807/
│   │   ├── scaffolds.fasta
│   │   └── contigs.fasta
│   └── SRR31305919/
│       ├── scaffolds.fasta
│       └── contigs.fasta
├── quast/
│   ├── SRR31122807/
│   │   └── report.txt
│   └── SRR31305919/
│       └── report.txt
├── prokka/
│   ├── SRR31122807/
│   │   └── PROKKA_11132024.gff
│   └── SRR31305919/
│       └── PROKKA_11132024.gff
└── abricate/
    ├── SRR31122807/
    │   ├── results_ncbi.tab
    │   ├── results_resfinder.tab
    │   └── results_vfdb.tab
    └── SRR31305919/
        ├── results_ncbi.tab
        ├── results_resfinder.tab
        └── results_vfdb.tab
Customization
You can customize the pipeline by modifying the params.json file and the Snakefile. The params.json file allows you to configure tool-specific parameters, while the Snakefile allows you to modify the pipeline steps and dependencies.

Skipping Steps
You can skip specific steps by adding the sample prefix to the skip_steps list in the Snakefile. For example:

python
Copy
skip_steps = {
    'prefix': ['SRR292678sub']
}
This will skip the FastQC and SPAdes steps for samples with the prefix SRR292678sub.

Examples
Running the Pipeline with Default Parameters
bash
Copy
snakemake --use-conda --cores 8
Running the Pipeline with Increased Latency Wait
bash
Copy
snakemake --use-conda --cores 8 --latency-wait 60
Running the Pipeline with Specific Samples
bash
Copy
snakemake --use-conda --cores 8 --samples SRR31122807 SRR31305919
Troubleshooting
If you encounter any issues while running the pipeline, please check the following:

Input Files: Ensure that the input FASTQ files are correctly named and placed in the test_input directory.

Permissions: Ensure that you have the necessary permissions to read and write files in the working directory.

Dependencies: Ensure that all required tools are installed and available in the Conda environment.

License
This project is licensed under the MIT License. See the LICENSE file for details.

Feel free to contribute to this project by submitting issues or pull requests. Happy bioinformatics!


https://www.ncbi.nlm.nih.gov/sra/docs/sradownload/ здесь инструкция как искать и качать

Установить sra-tools через conda с скачать данные Covid:
conda install -c bioconda -c conda-forge sra-tools
prefetch SRR31122807 

добавить риды и сборки в test_input

conda create -n snakemake -c conda-forge snakemake
fastq-dump --split-files --gzip SRR31122807.sra
fastqc SRR31122807_1.fastq.gz  SRR31122807_2.fastq.gz
spades.py -1 SRR31305919_1.fastq.gz -2 SRR31305919_2.fastq.gz -o spades_output
quast.py contigs.fasta scaffolds.fasta -o ../quast/
prokka --outdir ./prokka ./spades/scaffolds.fasta

abricate --db ncbi ../spades/scaffolds.fasta > results_ncbi.tab
# abricate --db resfinder ../spades/scaffolds.fasta > results_resfinder.tab


snakemake --use-conda
snakemake --use-conda --conda-frontend mamba -j 4

Сообщение об ошибке указывает, что Snakemake больше не поддерживает установку окружений с использованием альтернативных интерфейсов для conda, таких как mamba. Вместо этого Snakemake теперь полагается на улучшения в стандартном conda, включая libmamba для быстрого решения зависимостей.

snakemake --use-conda -j 4

