
https://www.ncbi.nlm.nih.gov/sra/docs/sradownload/ здесь инструкция как искать и качать

Установить sra-tools через conda с скачать данные Covid:
conda install -c bioconda -c conda-forge sra-tools
prefetch SRR31122807 


conda create -n snakemake -c conda-forge snakemake
fastq-dump --split-files --gzip SRR31122807.sra
fastqc SRR31122807_1.fastq.gz  SRR31122807_2.fastq.gz
spades.py -1 SRR31305919_1.fastq.gz -2 SRR31305919_2.fastq.gz -o spades_output

добавить риды и сборки в test_input






snakemake --use-conda