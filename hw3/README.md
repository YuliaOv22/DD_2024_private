
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




snakemake --use-conda
snakemake --use-conda --conda-frontend mamba -j 4

Сообщение об ошибке указывает, что Snakemake больше не поддерживает установку окружений с использованием альтернативных интерфейсов для conda, таких как mamba. Вместо этого Snakemake теперь полагается на улучшения в стандартном conda, включая libmamba для быстрого решения зависимостей.

snakemake --use-conda -j 4

