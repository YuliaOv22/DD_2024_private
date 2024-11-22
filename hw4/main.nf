#!/usr/bin/env nextflow

params.sample_id = "SRR31122807"
params.indir = "$projectDir/test_input/"
params.outdir = "$projectDir/test_output/"
params.reads = "$params.indir/${params.sample_id}_{1,2}.fastq.gz"
params.scaffolds_file = "$params.outdir/$params.sample_id/${params.sample_id}_scaffolds.fasta"
params.contigs_file = "$params.outdir/$params.sample_id/${params.sample_id}_contigs.fasta"

log.info """\
    F S Q P A - N F   P I P E L I N E
    ===================================
    scaffolds_file        : ${params.scaffolds_file}
    reads                 : ${params.reads}
    indir                 : ${params.indir}
    outdir                : ${params.outdir}
    sample_id             : ${params.sample_id}
    """
    .stripIndent()

// Контроль качества ридов (FastQC)
process FASTQC {

    publishDir "${params.outdir}", mode: 'copy'

    tag "FASTQC on $sample_id"

    input:
    tuple val(sample_id), path(reads)

    output:
        path "fastqc"

    script:
        """
        mkdir fastqc
        fastqc ${reads} -o fastqc
        """
}

// Сборка генома (SPAdes)
process SPADES {

    publishDir "${params.outdir}", mode: 'copy'

    tag "SPADES on $sample_id"

    input:
        tuple val(sample_id), path(reads)

    output:
        path "spades/${sample_id}"

    script:
        """
        mkdir spades
        spades.py -1 ${reads[0]} -2 ${reads[1]} -o spades/${sample_id}
        """
}

// Оценка качества сборки (QUAST)
process QUAST {

    publishDir "${params.outdir}", mode: 'copy'

    tag "QUAST on $sample_id"

    input:
        tuple val(sample_id), 
        path("$params.outdir/spades/${sample_id}/${sample_id}_scaffolds.fasta"), 
        path("$params.outdir/spades/${sample_id}/${sample_id}_contigs.fasta")

    output:
        path "quast/${sample_id}"

    script:
        """
        mkdir quast
        quast.py ${scaffolds_file} ${contigs_file} -o quast/${sample_id}
        """
}

workflow {
    println '-----Read files-----'
    Channel
        .fromFilePairs(params.reads, checkIfExists: true)
        .view()
        .set { read_pairs_ch } 

    fastqc_ch = FASTQC(read_pairs_ch)    
    spades_ch = SPADES(read_pairs_ch) | view
    quast_ch = QUAST(read_pairs_ch) | view
}
