process CAT_FASTA {
    tag "$meta.id"
    label 'process_low'

    conda (params.enable_conda ? "conda-forge::sed=4.7" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/cat:5.2.3--hdfd78af_1':
        'quay.io/biocontainers/cat:5.2.3--hdfd78af_1' }"

    input:
    tuple val(meta), path(fastas)

    output:
    tuple val(meta), path(merged_fasta), emit: fasta
    path "versions.yml"           , emit: versions

    script:
    def args = task.ext.args ?: ''
    def prefix = "${meta.id}." + task.ext.prefix ?: "${meta.id}"
    merged_fasta = prefix + ".fasta"

    """
    cat $fastas > $merged_fasta

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        cat: 4.7
    END_VERSIONS
    """
}
