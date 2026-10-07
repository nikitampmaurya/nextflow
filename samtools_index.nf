#!/usr/bin/env nextflow
// Tells the system to run this script using Nextflow.

/*
 * This process called "SAMTOOLS_INDEX" will be used to generate BAM index file
 */
process SAMTOOLS_INDEX {

    container 'community.wave.seqera.io/library/samtools:1.20--b5dfbd93de237464'
    // Use a Docker container containing Samtools 1.20 to run this process.

    input:
    path input_bam  // Input the BAM file that needs to be indexed.

    output:
    tuple path(input_bam), path("${input_bam}.bai") // Output the original BAM file together with its BAM index (.bai) as a tuple.

    script:
    """
    samtools index ${input_bam} // Run Samtools index to create an index (.bai) for the BAM file.
    """
}
