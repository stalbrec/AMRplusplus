process RunDeeparg {
    tag { sample_id }
    conda "$baseDir/envs/deepARG.yml"
    label 'deeparg'
    publishDir "${params.output}/DeepARG/", mode: "copy"
    input:
        tuple val(sample_id), path(reads) 
        path(deepargdb)
    output:
        tuple val(sample_id), path("${sample_id}.mapping.*"), emit: ARG_mappings

    """
        zcat $reads > reads.fasta
        deeparg predict --model LS -d $deepargdb --type nucl --min-prob 0.8 \
        --arg-alignment-identity 30 \
        --arg-alignment-evalue 1e-10 \
        --arg-num-alignments-per-entry 1000 \
        -i reads.fasta \
        -o $sample_id
    """
}

process RunDeepargSS {
    tag { sample_id }
    conda "$baseDir/envs/deepARG.yml"
    label 'deeparg'
    publishDir "${params.output}/DeepARG/", mode: "copy"
    input:
        tuple val(sample_id), path(reads) 
        path(deepargdb)
        val modelVersion
        val customModel 
    output:
        tuple val(sample_id), path("${sample_id}.mapping.*"), emit: ARG_mappings

    """
        deeparg $customModel short_reads_pipeline -d $deepargdb \
        --forward_pe_file ${reads[0]} \
        --reverse_pe_file ${reads[1]} \
        --output_file $sample_id \
        --bowtie_16s_identity 100 \
        --deeparg_model_version $modelVersion
        for outfile in ARG potential.ARG ARG.merged ARG.merged.quant ARG.merged.quant.type ARG.merged.quant.subtype
        do
            mv ${sample_id}.clean.deeparg.mapping.\${outfile} ${sample_id}.mapping.\${outfile}
        done    
    """
}