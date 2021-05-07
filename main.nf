#!/usr/bin/env nextflow

// This is needed for activating the new DLS2
nextflow.enable.dsl=2


println """\
      LIST OF PARAMETERS
================================
            GENERAL
Data-folder      : $params.datadir
Results-folder   : $params.outdir

...

================================
"""


// Also channels are being created. 
read_pairs_ch = Channel
        .fromFilePairs(params.reads, checkIfExists:true)

genome = file(params.genome)
//gtf = file(params.gtf)
//bt2idx = file(params.bt2idx)

include { fastqc as fastqc_raw; fastqc as fastqc_trim } from "${launchDir}/modules/fastqc" //addParams(OUTPUT: fastqcOutputFolder)
include { trimmomatic } from "${launchDir}/modules/trimmomatic"
include { kseq_test } from "${launchDir}/modules/kseq_test"
include { bowtie_idx; bowtie_alignment } from "${launchDir}/modules/bowtie"
include { multiqc } from "${launchDir}/modules/multiqc" 

// Running a workflow with the defined processes here.  
workflow {
  // QC on raw reads
  fastqc_raw(read_pairs_ch) 
	
  // Trimming & QC
  trimmomatic(read_pairs_ch)
	
  // kseq_test
  kseq_test(trimmomatic.out.trim_fq)

  // Mapping
  bowtie_idx(genome)
  bowtie_alignment(kseq_test.out.kseq_test_fq, (bowtie_idx.out.index).collect())
  
  // Multi QC on all results
  //multiqc((fastqc_raw.out.fastqc_out).mix(fastqc_trim.out.fastqc_out).collect())
}
