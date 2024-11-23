#!/usr/bin/env nextflow

params.sample_id = "SRR31122807"
params.indir = "${projectDir}/test_input"
params.outdir = "${projectDir}/test_output"
params.reads = "${params.indir}/${params.sample_id}_{1,2}.fastq.gz"
params.scaffolds_fasta_file = "${params.outdir}/spades/${params.sample_id}/scaffolds.fasta"
params.contigs_fasta_file = "${params.outdir}/spades/${params.sample_id}/contigs.fasta"

log.info """\
    F S Q P A - N F   P I P E L I N E
    ===================================    
    indir                 : ${params.indir}
    outdir                : ${params.outdir}
    reads                 : ${params.reads}
    scaffolds             : ${params.scaffolds_fasta_file}
    contigs               : ${params.contigs_fasta_file}

    """
    .stripIndent()

// Контроль качества ридов (FastQC)
process FASTQC {

    publishDir "${params.outdir}/", mode: 'copy'

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

    publishDir "${params.outdir}/", mode: 'copy'

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

    publishDir "${params.outdir}/", mode: 'copy'

    tag "QUAST on $sample_id"

    input:         
        tuple val(sample_id), path(scaffolds), path(contigs)

    output:
        path "quast/${sample_id}"

    script:
        """
        mkdir -p quast
        quast.py ${scaffolds} ${contigs} -o quast/${sample_id}
        """
}

workflow {
    Channel
        .fromFilePairs(params.reads, checkIfExists: true)  
        .set { read_pairs_ch }

    FASTQC(read_pairs_ch) | view { println "\n-----FASTQC out----- \n$it"}
    SPADES(read_pairs_ch) | view { println "\n-----SPADES out-----\n$it"}

    quast_ch = SPADES.out.map { dir ->
        def sample_id = dir.getName()
        def scaffolds = file("${dir}/scaffolds.fasta")
        def contigs = file("${dir}/contigs.fasta")
        return tuple(sample_id, scaffolds, contigs)
    }

    QUAST(quast_ch) | view { println "\n-----QUAST out-----\n$it" }
}
