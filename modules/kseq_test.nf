#!/usr/bin/env nextflow

// This is needed for activating the new DLS2
nextflow.enable.dsl=2


process kseq_test {
  publishDir "$params.outdir/kseq-test/", mode: 'copy', overwrite: true
  label 'low'
  container 'umichbfxcore/cutruntools:0.1.0'
  
  input:
  tuple val(sample), path(reads)

  output:
  tuple val("${sample}"), path("${sample}*.kseq.fq"), emit: kseq_test_fq

  script:
  //mkdir -p $params.outdir/quality-control-$sample/  
  """
  kseq_test ${reads[0]} ${params.len} ${sample}1.kseq.fq
  kseq_test ${reads[1]} ${params.len} ${sample}2.kseq.fq
  """
}
