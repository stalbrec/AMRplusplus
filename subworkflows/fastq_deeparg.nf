// Load modules
include { RunDeeparg } from '../modules/Inference/deeparg.nf' 

workflow FASTQ_DEEPARG_WF {
    take: 
        read_pairs_ch
        deepargdb

    main:
        println "using database from $deepargdb"
        if(deepargdb && file(deepargdb).exists() ){
            if(workflow.profile == "conda"){
                RunDeeparg(read_pairs_ch, deepargdb)|view {it}
            } else {
                println "WARNING: In order to use deepARG you need to use the conda profile!"
            }
        }else{
            println "ERROR: provided deeparg data directory ($deepargdb) does not exists!"
        }
}
