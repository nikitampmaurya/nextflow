#!/usr/bin/env nextflow
// to tell the system to run this script using Nextflow


/*
 * Call variants with GATK HaplotypeCaller
 */
process GATK_HAPLOTYPECALLER {

    container 'community.wave.seqera.io/library/gatk4:4.5.0.0--730ee8817e436867'
    // Use a Docker container containing GATK 4.5.0.0 to run this process

    input:
    tuple path(input_bam), path(input_bam_index)  // take the BAM file and its index file together as a tuple
    path ref_fasta   // input the reference genome FASTA file containing the reference DNA sequence
    path ref_index // input the FASTA index (.fai), which allows software to quickly access specific regions of the reference genome
    path ref_dict  // Input the GATK sequence dictionary, which contains information about the reference genome's chromosomes/contigs
    path interval_list  // Input the BED/interval file specifying which genomic regions should be analysed

    output:
    path "${input_bam}.g.vcf"     , emit: vcf
    // Output the GVCF file containing variant information for this sample
    // "emit: vcf" gives this output a name that can be used elsewhere in the workflow.


    path "${input_bam}.g.vcf.idx" , emit: idx
    // Output the GVCF index file (.idx)
    // "emit: idx" gives this output a name that can be used elsewhere in the workflow

    script:
    """
    gatk HaplotypeCaller \
        -R ${ref_fasta} \
        -I ${input_bam} \
        -O ${input_bam}.g.vcf \
        -L ${interval_list} \
        -ERC GVCF
    """
}
