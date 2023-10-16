process RunDeeparg {
    tag { sample_id }
    conda "$baseDir/envs/deepARG.yml"
    label 'deeparg'
    input:
        tuple val(sample_id), path(bam)
        path(deepargdb)
    output:
        stdout

    """
        echo "hello world"
        echo $sample_id
        echo $bam
        echo $deepargdb
        which python
    """
}