#!/usr/bin/env nextflow

// This is needed for activating the new DLS2
nextflow.enable.dsl=2


println """\
      LIST OF PARAMETERS
================================
            GENERAL
Data-folder      : $params.projdir
Results-folder   : $params.outdir

================================
      INPUT & REFERENCES 
Input-files      : $params.reads
Reference genome : $params.genome
GTF-file         : $params.gtf

================================
          TRIMMOMATIC
Sliding window   : $params.slidingwindow
Average quality  : $params.avgqual

================================
             STAR
Length-reads     : $params.lengthreads
SAindexNbases    : $params.genomeSAindexNbases

================================
"""


// Also channels are being created. 
read_pairs_ch = Channel
        .fromFilePairs(params.reads, checkIfExists:true)

genome = file(params.genome)
gtf = file(params.gtf)

include { fastqc as fastqc_raw; fastqc as fastqc_trim } from "${launchDir}/modules/fastqc" //addParams(OUTPUT: fastqcOutputFolder)
include { star_idx; star_alignment } from "${launchDir}/modules/star"
include { trimmomatic } from "${launchDir}/modules/trimmomatic"
include { multiqc } from "${launchDir}/modules/multiqc" 

// Running a workflow with the defined processes here.  
workflow {
  // QC on raw reads
  fastqc_raw(read_pairs_ch) 
	
  // Trimming & QC
  trimmomatic(read_pairs_ch)
  fastqc_trim(trimmomatic.out.trim_fq)
	
  // Mapping
  star_idx(genome, gtf)
  star_alignment(trimmomatic.out.trim_fq, star_idx.out.index, gtf)
  
  // Multi QC on all results
  multiqc((fastqc_raw.out.fastqc_out).mix(fastqc_trim.out.fastqc_out).collect())
}
