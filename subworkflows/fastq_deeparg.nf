// Load modules
include { RunDeeparg; RunDeepargSS } from '../modules/Inference/deeparg.nf' 

workflow FASTQ_DEEPARG_WF {
    take: 
        read_pairs_ch
        deepargdb
        short_reads_pipeline

    main:
        println "using database from $deepargdb"
        if(deepargdb && file(deepargdb).exists() ){
            if(workflow.profile == "conda"){
                if (short_reads_pipeline == true) {
                    RunDeepargSS(read_pairs_ch, deepargdb)
                } else {
                    RunDeeparg(read_pairs_ch, deepargdb)
                }
            } else {
                error "In order to use deepARG you need to use the conda profile!"
            }
        }else{
            error "The provided deeparg data directory ($deepargdb) does not exists!"
        }
}