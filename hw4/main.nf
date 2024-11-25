#!/usr/bin/env nextflow



log.info """\
    F S Q P A - N F   P I P E L I N E
    ===================================    
    indir                 : ${params.indir}
    outdir                : ${params.outdir}
    parse_csv             : ${params.parse_csv}
    databases             : ${params.databases}
    """
    .stripIndent()

// Контроль качества ридов (FastQC)
process FASTQC {

    publishDir { params.paths.fastqc(sample_id) }, mode: 'copy'

    tag "FASTQC on $sample_id"

    input:
        tuple val(sample_id), path(reads)

    output:
        path "*_fastqc.{zip,html}"

    script:
        """
        fastqc ${reads}
        """
}

// Сборка генома (SPAdes)
process SPADES {

    publishDir { params.paths.spades(sample_id) }, mode: 'copy'

    tag "SPADES on $sample_id"

    input:
        tuple val(sample_id), path(reads)

    output:
        tuple val(sample_id), path("*s.fasta"), emit: assembly_output

    script:
        """
        spades.py -1 ${reads[0]} -2 ${reads[1]} -o ./
        """
}

// Оценка качества сборки (QUAST)
process QUAST {

    publishDir { params.paths.quast(sample_id) }, mode: 'copy'

    tag "QUAST on $sample_id"

    input:         
        // tuple val(sample_id), path(scaffolds), path(contigs)
        tuple val(sample_id), path(scaffolds)

    output:
        path("report.txt")

    script:
        // """
        // quast.py ${scaffolds} ${contigs} -o ${sample_id}
        // """
        """
        quast.py ${scaffolds} -o ./
        """
}

// Аннотация генома (PROKKA)
process PROKKA {

    publishDir { params.paths.prokka(sample_id) }, mode: 'copy'

    tag "PROKKA on $sample_id"

    input:         
        tuple val(sample_id), path(scaffolds)

    output:
        path("*.gff")

    script:
        """
        prokka --outdir ./ --force ${scaffolds} 
        """
}

// Поиск генов устойчивости и вирулентности (ABRICATE)
process ABRICATE {

    publishDir { params.paths.abricate(sample_id) }, mode: 'copy'

    tag "ABRICATE on $sample_id using $db"

    input:         
        tuple val(sample_id), path(scaffolds), val(db)

    output:
        path("results_${db}.tab")

    script:
        """   
        mkdir -p ${sample_id}
        abricate --db ${db} ${scaffolds} > ./results_${db}.tab  \
        || echo "No results found" > ./results_${db}.tab         
        """
}


workflow {

    // Парсинг файла samples.csv
    Channel
        .fromPath(params.parse_csv)
        .splitCsv(skip: 1)
        .map { row ->         
            def sample_id = row[0]
            def reads = (params.indir + row[1] + ', ' + params.indir + row[2])
                ?.replaceAll(/[\[\]]/, '') 
                ?.split(',')
                ?: []
            def assembly = row[3] ?: null
            
            // Создаем пути для выходов процессов
            def sample_paths = [
                fastqc: params.paths.fastqc(sample_id),
                spades: params.paths.spades(sample_id),
                quast: params.paths.quast(sample_id),
                prokka: params.paths.prokka(sample_id),
                abricate: params.paths.abricate(sample_id),
            ]
                   
            return tuple(sample_id, reads, assembly, sample_paths)
            
        }
        .branch {
            need_assembly: it[2] == null
            has_assembly: it[2] != null
        }
        .set { samples_ch }
    

    // ОБРАЗЦЫ БЕЗ СБОРКИ
    no_assembly(samples_ch.need_assembly)

    // ОБРАЗЦЫ СО СБОРКОЙ
    exist_assembly(samples_ch.has_assembly)
}

workflow no_assembly {

    take:
    samples_ch

    main:
    
    // Создаем канал для FASTQC из образцов, требующих сборки
    def read_pairs_ch = samples_ch
        .map { sample_id, reads, assembly, paths ->
            // Создаем паттерн для fromFilePairs из путей к ридам
            def pattern = reads.collect { it.trim() }  // получаем пути к файлам
            return tuple(sample_id, pattern)
        } 
    
    // Запуск процесса FASTQC
    FASTQC(read_pairs_ch)
    
    // Запуск процесса SPADES
    SPADES(read_pairs_ch)

    // Канал для записи выхода сборки генома
    spades_ch = SPADES.out
        .map { it ->
            def sample_id = it[0]
            def scaffolds = file(it[1][1])
            return tuple(sample_id, scaffolds)
        }    
            
    // Запуск процесса QUAST
    QUAST(spades_ch)

    // PROKKA(spades_filtered_ch)
    PROKKA(spades_ch)
    
    // Канал для поиска генов устойчивости и вирулентности
    abricate_ch = spades_ch
        .combine(Channel.fromList(params.databases))
        .map { sample_id, scaffolds, db -> 
            tuple(sample_id, scaffolds, db) 
        }

    // Запуск процесса ABRICATE
    ABRICATE(abricate_ch)  

}

workflow exist_assembly {

    take:
    samples_ch

    main:
    
    // Канал для записи выхода сборки генома
    scaffolds_fasta_ch = samples_ch
        .map { sample_id, reads, assembly, paths ->
            def scaffolds = file("${params.indir}/${assembly}")
            return tuple(sample_id, scaffolds)
        } 
   
    // Запуск процесса QUAST
    QUAST(scaffolds_fasta_ch)    

    // Запуск процесса PROKKA
    PROKKA(scaffolds_fasta_ch)

    // Канал для поиска генов устойчивости и вирулентности
    abricate_ch = scaffolds_fasta_ch
        .combine(Channel.fromList(params.databases))
        .map { sample_id, scaffolds, db -> 
            tuple(sample_id, scaffolds, db) 
        }

    // Запуск процесса ABRICATE
    ABRICATE(abricate_ch)

    }