include { FASTQ_QC_WF } from "$baseDir/subworkflows/fastq_information.nf"
include { FASTQ_TRIM_WF } from "$baseDir/subworkflows/fastq_QC_trimming.nf"
include { FASTQ_RM_HOST_WF } from "$baseDir/subworkflows/fastq_host_removal.nf" 
include { FASTQ_RESISTOME_WF } from "$baseDir/subworkflows/fastq_resistome.nf"
include { FASTQ_ALIGNMENT_WF } from "$baseDir/subworkflows/fastq_alignment.nf"
include { FASTQ_DEEPARG_WF } from "$baseDir/subworkflows/fastq_deeparg.nf"

workflow STANDARD_AMRplusplus_wDeepARG {
    take: 
        read_pairs_ch
        hostfasta
        amr
        annotation
        deepargdb
        deepargVersion

    main:
        // fastqc
        FASTQ_QC_WF( read_pairs_ch )
        // runqc trimming
        FASTQ_TRIM_WF(read_pairs_ch)
        // remove host DNA
        // FASTQ_RM_HOST_WF(hostfasta, FASTQ_TRIM_WF.out.trimmed_reads)
        // AMR alignment
        // FASTQ_RESISTOME_WF(FASTQ_RM_HOST_WF.out.nonhost_reads, amr, annotation)
        // DeepARG Inference
        // FASTQ_DEEPARG_WF(FASTQ_RM_HOST_WF.out.nonhost_reads, deepargdb, false)
        FASTQ_RESISTOME_WF(FASTQ_TRIM_WF.out.trimmed_reads, amr, annotation)
        FASTQ_DEEPARG_WF(read_pairs_ch, deepargdb, deepargVersion, true, false)
}

workflow STANDARD_AMRplusplus_wCustomDeepARG {
    take: 
        read_pairs_ch
        hostfasta
        amr
        annotation
        deepargdb
        deepargVersion

    main:
        // fastqc
        FASTQ_QC_WF( read_pairs_ch )
        // runqc trimming
        FASTQ_TRIM_WF(read_pairs_ch)
        // remove host DNA
        // FASTQ_RM_HOST_WF(hostfasta, FASTQ_TRIM_WF.out.trimmed_reads)
        // AMR alignment
        // FASTQ_RESISTOME_WF(FASTQ_RM_HOST_WF.out.nonhost_reads, amr, annotation)
        // DeepARG Inference
        // FASTQ_DEEPARG_WF(FASTQ_RM_HOST_WF.out.nonhost_reads, deepargdb, false)
        FASTQ_RESISTOME_WF(FASTQ_TRIM_WF.out.trimmed_reads, amr, annotation)
        FASTQ_DEEPARG_WF(read_pairs_ch, deepargdb, deepargVersion, true, true)
}
