process SPALN_ALIGN {
    tag "$meta.id | $meta_p.id"
    label 'process_high'

    conda (params.enable_conda ? "bioconda::spaln=2.4.7" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/spaln:2.4.7--pl5321hd03093a_2':
        'quay.io/biocontainers/spaln:2.4.7--pl5321hd03093a_2' }"
                        
    input:
    tuple val(meta), path(spaln_index)
    tuple val(meta_p), path(proteins)
    val spaln_q
    val spaln_taxon
    val spaln_options

    output:
    tuple val(meta_p),path("${chunk_name}.*rd"), optional: true, emit: align
    path "versions.yml"           , emit: versions

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    chunk_name = proteins.getBaseName()

    // From the bad idea department - spaln can segfault on certain protein inputs.
    // Rather than have the user debug for hours, we gracefully omit this chunk instead (mostly harmless since we heavily partition the proteins)
    """
    spaln -o $chunk_name -Q${spaln_q} -T${spaln_taxon} ${spaln_options} -O12 -t${task.cpus} -dgenome_spaln $proteins |:

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        spaln: \$(echo \$( spaln 2>&1 | head -n3 | tail -n1 | cut -f4 -d " " ))
    END_VERSIONS
    """
}
