#!/usr/bin/env nextflow
// to tell the system to run this script using Nextflow

/*
 * combine all GVCFs into GenomicsDB datastore and run joint genotyping to produce cohort-level calls
 */
process GATK_JOINTGENOTYPING {

    container "community.wave.seqera.io/library/gatk4:4.5.0.0--730ee8817e436867"
     // use a Docker container containing GATK 4.5.0.0 to run this process

    input:
    path all_gvcfs  // input all GVCF files produced by HaplotypeCaller for the samples in the cohort
    path all_idxs // input the index files corresponding to the GVCFs
    path interval_list // input the BED/interval file specifying which genomic regions should be analysed
    val cohort_name // input the name of the cohort as a value rather than a file, used to name the GenomicsDB workspace and final output files.
    path ref_fasta  // input the reference genome FASTA file
    path ref_index // input the FASTA index (.fai), which allows efficient access to regions of the reference genome.
    path ref_dict // input the GATK sequence dictionary containing information about the reference genome's chromosomes/contigs.

    output:
    path "${cohort_name}.joint.vcf"     , emit: vcf
    // output the final cohort-level VCF containing the jointly genotyped variants
    // "emit: vcf" gives this output a name that can be used elsewhere in the workflow

    path "${cohort_name}.joint.vcf.idx" , emit: idx
    // output the index of the final joint VCF.
    // "emit: idx" gives this output a name that can be used elsewhere in the workflow.

    script:
    def gvcfs_line = all_gvcfs.collect { gvcf -> "-V ${gvcf}" }.join(' ')
    // convert all input GVCF files into a series of GATK "-V" arguments.
    // e.g. three GVCFs become: -V sample1.g.vcf -V sample2.g.vcf -V sample3.g.vcf

    """
    gatk GenomicsDBImport \
        ${gvcfs_line} \
        -L ${interval_list} \
        --genomicsdb-workspace-path ${cohort_name}_gdb

    // import the GVCFs into a GenomicsDB workspace
    // ${gvcfs_line} provides all the input GVCFs
    // -L specifies the genomic regions to analyse
    // --genomicsdb-workspace-path specifies where the GenomicsDB workspace will be created

    gatk GenotypeGVCFs \
        -R ${ref_fasta} \
        -V gendb://${cohort_name}_gdb \
        -L ${interval_list} \
        -O ${cohort_name}.joint.vcf

    // to perform joint genotyping using the GVCF information stored in GenomicsDB.
    // -R specifies the reference genome
    // -V gendb:// specifies the GenomicsDB workspace as the input
    // -L specifies the genomic regions to analyse
    // -O specifies the final cohort-level VCF output


    """
}
