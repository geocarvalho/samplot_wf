#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    SAMPLOT PIPELINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Structural Variant Visualization Pipeline using samplot
----------------------------------------------------------------------------------------
*/

// Include the samplot module
include { SAMPLOT_PLOT } from './modules/samplot/main'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

// Function to parse samplesheet
def parseSamplesheet(samplesheet) {
    def samples = []
    
    samplesheet.splitCsv(header: true, strip: true).each { row ->
        // Validate required columns
        if (!row.sample_name) {
            error "Missing 'sample_name' column in samplesheet: ${row}"
        }
        if (!row.alignment) {
            error "Missing 'alignment' column in samplesheet: ${row}"
        }
        if (!row.index) {
            error "Missing 'index' column in samplesheet: ${row}"
        }
        
        // Check if files exist
        def alignment_file = file(row.alignment, checkIfExists: true)
        def index_file = file(row.index, checkIfExists: true)
        
        samples.add([
            sample_name: row.sample_name,
            alignment: alignment_file,
            index: index_file
        ])
    }
    
    return samples
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    PARAMETER VALIDATION
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

// Validate required parameters
if (!params.input) {
    error "Please provide a samplesheet with --input"
}
if (!params.chrom) {
    error "Please provide chromosome with --chrom"
}
if (!params.start) {
    error "Please provide start position with --start"
}
if (!params.end) {
    error "Please provide end position with --end"
}
if (!params.sv_type) {
    error "Please provide SV type with --sv_type"
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {
    
    // Read and parse samplesheet
    ch_samplesheet = Channel.fromPath(params.input, checkIfExists: true)
    
    ch_samples = ch_samplesheet
        .splitCsv(header: true, strip: true)
        .map { row ->
            // Validate required columns
            if (!row.sample_name) {
                error "Missing 'sample_name' column in samplesheet: ${row}"
            }
            if (!row.alignment) {
                error "Missing 'alignment' column in samplesheet: ${row}"
            }
            if (!row.index) {
                error "Missing 'index' column in samplesheet: ${row}"
            }
            
            // Check if files exist
            def alignment_file = file(row.alignment, checkIfExists: true)
            def index_file = file(row.index, checkIfExists: true)
            
            return [
                sample_name: row.sample_name,
                alignment: alignment_file,
                index: index_file
            ]
        }
        .collect()
        .map { samples ->
            // Extract sample names, alignment files, and index files
            def sample_names = samples.collect { it.sample_name }
            def alignment_files = samples.collect { it.alignment }
            def index_files = samples.collect { it.index }
            
            // Create meta map
            def meta = [
                id: "samplot_${params.chrom}_${params.start}_${params.end}",
                sample_names: sample_names,
                chrom: params.chrom,
                start: params.start,
                end: params.end,
                sv_type: params.sv_type,
                window: params.window,
                max_depth: params.max_depth,
                plot_height: params.plot_height,
                plot_width: params.plot_width,
                include_mqual: params.include_mqual,
                output_file: params.output_file
            ]
            
            return [meta, alignment_files, index_files]
        }
    
    // Prepare reference file channel
    ch_reference = params.reference ? 
        Channel.fromPath(params.reference) : 
        Channel.value(file('NO_FILE_REF'))
    
    // Prepare transcript file channel
    ch_transcript = params.transcript_file ? 
        Channel.fromPath(params.transcript_file) : 
        Channel.value(file('NO_FILE_TRANSCRIPT'))
    
    // Prepare transcript file index channel
    ch_transcript_index = params.transcript_file_index ? 
        Channel.fromPath(params.transcript_file_index) : 
        Channel.value(file('NO_FILE_TRANSCRIPT_INDEX'))
    
    // Prepare annotation files channel
    ch_annotations = params.annotation_files ? 
        Channel.fromPath(params.annotation_files.tokenize(' ')).collect() : 
        Channel.value([file('NO_FILE_ANNOTATION')])
    
    // Prepare annotation files index channel
    ch_annotations_index = params.annotation_files_index ? 
        Channel.fromPath(params.annotation_files_index.tokenize(' ')).collect() : 
        Channel.value([file('NO_FILE_ANNOTATION_INDEX')])
    
    // Run samplot
    SAMPLOT_PLOT(
        ch_samples,
        params.chrom,
        params.start,
        params.end,
        params.sv_type,
        ch_reference,
        ch_transcript,
        ch_transcript_index,
        ch_annotations,
        ch_annotations_index
    )
    
    // Print completion message
    SAMPLOT_PLOT.out.plot.view { meta, plot ->
        "Generated samplot visualization: ${plot}"
    }
}