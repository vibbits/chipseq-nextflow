#!/usr/bin/env nextflow

// This is needed for activating the new DLS2
nextflow.enable.dsl=2

// Process trimmomatic
process trimmomatic {
    publishDir "$params.outdir/trimmed-reads", mode: 'copy' , overwrite: true
    label 'low'
    container 'quay.io/biocontainers/trimmomatic:0.35--6'

    // Same input as fastqc on raw reads, comes from the same channel. 
    input:
    tuple val(sample), path(reads) 

    output:
    tuple val("${sample}"), path("${sample}*.paired.fq"), emit: trim_fq
    tuple val("${sample}"), path("${sample}*.unpaired.fq"), emit: untrim_fq
    
    script:
    """
    mkdir -p $params.outdir/trimmed-reads/
    trimmomatic PE \\
        -threads $params.threads \\
        ${reads[0]} \\
        ${reads[1]} \\
        ${sample}1.paired.fq \\
        ${sample}1.unpaired.fq \\
        ${sample}2.paired.fq \\
        ${sample}2.unpaired.fq \\
        $params.illuminaclip \\
        $params.leading \\
        $params.trailing \\
        $params.slidingwindow \\
        $params.minlen 
    """
}    

