include { FASTQ_QC_WF } from "$baseDir/subworkflows/fastq_information.nf"
include { FASTQ_TRIM_WF } from "$baseDir/subworkflows/fastq_QC_trimming.nf"
include { FASTQ_RM_HOST_WF } from "$baseDir/subworkflows/fastq_host_removal.nf" 
include { FASTQ_RESISTOME_WF } from "$baseDir/subworkflows/fastq_resistome.nf"
include { FASTQ_ALIGNMENT_WF } from "$baseDir/subworkflows/fastq_alignment.nf"

workflow STANDARD_AMRplusplus {
    take: 
        read_pairs_ch
        hostfasta
        amr
        annotation

    main:
        // fastqc
        FASTQ_QC_WF( read_pairs_ch )
        // runqc trimming
        FASTQ_TRIM_WF(read_pairs_ch)
        // remove host DNA
        FASTQ_RM_HOST_WF(hostfasta, FASTQ_TRIM_WF.out.trimmed_reads)
        // AMR alignment
        FASTQ_ALIGNMENT_WF(FASTQ_RM_HOST_WF.out.nonhost_reads, amr)
        // AMR lookup
        FASTQ_RESISTOME_WF(FASTQ_ALIGNMENT_WF.out.bwa_bam, amr, annotation, FASTQ_ALIGNMENT_WF.out.bwa_dedup_bam)

    //emit:
        //fastqc = fastqc.out   
        //multiqc = multiqc.out
        //trim_reads = runqc.out.paired_fastq
        //non_host_reads = bwa_rm_contaminant_fq.out.nonhost_reads
}