#!/usr/bin/env nextflow

// Определение путей к данным
def inputdir = file(params.indir)
def outputdir = file(params.outdir)
def samples_csv = file(params.samples_csv) 
def databases = params.databases
def params_spades = params.spades
def params_prokka = params.prokka

log.info """\
    F S Q P A - N F   P I P E L I N E
    ===================================    
    indir                 : ${inputdir}
    outdir                : ${outputdir}
    samples_csv           : ${samples_csv}
    databases             : ${databases}
    params_spades         : ${params_spades}
    params_prokka         : ${params_prokka}
    """
    .stripIndent()

// Контроль качества ридов (FASTQC)
process FASTQC {

    publishDir outputdir, mode: 'copy'

    tag "FASTQC on $sample_id"

    input:
        tuple val(sample_id), path(read_1), path(read_2)

    output:
        path("fastqc/${sample_id}/*")

    script:
        """
        mkdir -p fastqc/${sample_id}
        fastqc ${read_1} ${read_2} -o fastqc/${sample_id}
        """
}

// Сборка генома (SPADES)
process SPADES {

    publishDir outputdir, mode: 'copy'

    tag "SPADES on $sample_id"

    input:
        tuple val(sample_id), path(read_1), path(read_2)

    output:
        tuple val(sample_id), path("spades/${sample_id}/scaffolds.fasta")

    script:
        """
        mkdir -p spades/${sample_id}
        spades.py -1 ${read_1} -2 ${read_2} -o spades/${sample_id} -t ${params_spades.threads} -m ${params_spades.memory}
        """
}

// Оценка качества сборки (QUAST)
process QUAST {

    publishDir outputdir, mode: 'copy'

    tag "QUAST on $sample_id"

    input:         
        tuple val(sample_id), path(scaffolds)

    output:
        path("quast/${sample_id}/*")

    script:
        """
        mkdir -p quast/${sample_id}
        quast.py ${scaffolds} -o quast/${sample_id}
        """
}

// Аннотация генома (PROKKA)
process PROKKA {

    publishDir outputdir, mode: 'copy'

    tag "PROKKA on $sample_id"

    input:         
        tuple val(sample_id), path(assembly)

    output:
        path("prokka/${sample_id}/*")

    script:
        """
        mkdir -p prokka/${sample_id}
        prokka --outdir prokka/${sample_id} --force ${assembly} --genus ${params_prokka.genus}
        """
}

// Поиск генов устойчивости и вирулентности (ABRICATE)
process ABRICATE {

    publishDir outputdir, mode: 'copy'

    tag "ABRICATE on $sample_id using ${db}"

    input:         
        tuple val(sample_id), path(scaffolds), val(db)

    output:
        path("abricate/${sample_id}/results_${db}.tab")

    script:
        """   
        mkdir -p abricate/${sample_id}
        abricate --db ${db} ${scaffolds} > abricate/${sample_id}/results_${db}.tab  \
        || echo "No results found" > abricate/${sample_id}/results_${db}.tab         
        """
}


workflow {

    // Парсинг файла samples.csv
    Channel
        .fromPath(samples_csv)
        .splitCsv(header: true)
        .map { row ->         

            def sample_id = row.sample_id
            def read_1 = inputdir.resolve(row.read_1)
            def read_2 = inputdir.resolve(row.read_2)
            def assembly = row.assembly ? inputdir.resolve(row.assembly) : null

            [
                sample_id: row.sample_id,
                read_1: read_1,
                read_2: read_2,
                assembly: assembly
            ]
            
        }
        .branch {
            samples_with_assembly: it.assembly != null
            samples_without_assembly: it.assembly == null
        }
        .set { samples }
    

    FASTQC(samples.samples_without_assembly
        .map { tuple(it.sample_id, it.read_1, it.read_2)})

    SPADES(samples.samples_without_assembly
        .map { tuple(it.sample_id, it.read_1, it.read_2)})

    // Соединение сборок из папки test_input и процесса SPADES
    samples_all_assembly = samples.samples_with_assembly
        .map { tuple(it.sample_id, it.assembly) }
        .concat(SPADES.out)
   
    QUAST(samples_all_assembly)
    PROKKA(samples_all_assembly)

    // Добавление к сборкам баз данных
    samples_all_assembly_with_databases = samples_all_assembly
        .combine(Channel.fromList(databases))
        .map { sample_id, scaffolds, db -> 
            tuple(sample_id, scaffolds, db) 
        }

    ABRICATE(samples_all_assembly_with_databases)

}
