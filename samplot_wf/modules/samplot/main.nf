process SAMPLOT_PLOT {
    tag "${meta.id}"
    label 'samplot'
    
    input:
        tuple val(meta), path(alignment_files), path(index_files)
        val chrom
        val start
        val end
        val sv_type
        path reference, stageAs: 'reference.fa'
        path transcript_file 
        path transcript_file_index
        path annotation_files
        path annotation_files_index
    
    output:
        tuple val(meta), path("*.png"), emit: plot
        path "versions.yml", emit: versions
    
    when:
        task.ext.when == null || task.ext.when
    
    script:
        def args = task.ext.args ?: ''
        def prefix = task.ext.prefix ?: "${meta.id}"
        
        // Build the output filename
        def output_name = meta.output_file ?: "${sv_type}_${chrom}_${start}_${end}.png"
        
        // Build sample names argument
        def names_arg = "-n ${meta.sample_names.join(' ')}"
        
        // Build alignment files argument
        def alignments_arg = "-b ${alignment_files.join(' ')}"
        
        // Build reference argument
        def ref_arg = reference.name != 'NO_FILE_REF' ? "-r ${reference}" : ""
        
        // Build optional arguments
        def window_arg = meta.window ? "-w ${meta.window}" : ""
        def max_depth_arg = meta.max_depth ? "-d ${meta.max_depth}" : ""
        def plot_height_arg = meta.plot_height ? "-H ${meta.plot_height}" : ""
        def plot_width_arg = meta.plot_width ? "-W ${meta.plot_width}" : ""
        def include_mqual_arg = meta.include_mqual ? "-q ${meta.include_mqual}" : ""
        def sv_type_arg = sv_type ? "-t ${sv_type}" : ""
        
        // Build transcript file argument
        def transcript_arg = transcript_file.name != 'NO_FILE_TRANSCRIPT' ? "-T ${transcript_file}" : ""
        
        // Build annotation files argument
        def annotation_arg = ""
        if (annotation_files && annotation_files.size() > 0 && annotation_files[0].name != 'NO_FILE_ANNOTATION') {
            annotation_arg = "-A ${annotation_files.join(' ')}"
        }
        
        """
        samplot plot \\
            ${names_arg} \\
            ${alignments_arg} \\
            -o ${output_name} \\
            -c ${chrom} \\
            -s ${start} \\
            -e ${end} \\
            ${sv_type_arg} \\
            ${ref_arg} \\
            ${window_arg} \\
            ${max_depth_arg} \\
            ${plot_height_arg} \\
            ${plot_width_arg} \\
            ${include_mqual_arg} \\
            ${transcript_arg} \\
            ${annotation_arg} \\
            ${args}
        
        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            samplot: \$(samplot --version 2>&1 | grep -oP 'samplot \\K[0-9.]+' || echo "unknown")
        END_VERSIONS
        """
    
    stub:
        def output_name = meta.output_file ?: "${sv_type}_${chrom}_${start}_${end}.png"
        """
        touch ${output_name}
        
        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            samplot: \$(samplot --version 2>&1 | grep -oP 'samplot \\K[0-9.]+' || echo "unknown")
        END_VERSIONS
        """
}