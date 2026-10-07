#!/usr/bin/env nextflow
// to tell the system to run this script using Nextflow

// (Note: // is used for writing one line comments)


// import the SAMTOOLS_INDEX process from the samtools_index.nf module
// this process creates an index (.bai) for each input BAM file
include { SAMTOOLS_INDEX} from './modules/samtools_index.nf'

// import the GATK_HAPLOTYPECALLER process from the gatk_haplotypecaller.nf module
// this process calls variants and produces a GVCF for each sample
include { GATK_HAPLOTYPECALLER } from './modules/gatk_haplotypecaller.nf'

// import the GATK_JOINTGENOTYPING process from the gatk_jointgenotyping.nf module.
// this process combines the per-sample GVCFs and performs joint genotyping.
include { GATK_JOINTGENOTYPING } from './modules/gatk_jointgenotyping.nf'

/* Note: used for writing multi-line comments */

/*
Pipeline parameters
*/
 params {
        // "input" is the parameter name chosen providing the main input file to the pipeline.
        input: Path

        // Accessory files, these parameters names matches with the name in nextflow.config file
        reference: Path
        reference_index: Path
        reference_dict: Path
        intervals: Path

        // Base name for final output file
        cohort_name: String
 }

// Primary input

workflow { // everything inside describes the actual pipeline execution

    main: // where we define the pipeline's actual data flow and process calls.
    // channels are created before we call processes,
    // because the channel provides the data that the process needs
    // we create channel to accept input file which is a CSV file with two cols and second col containing one input file path.
    reads_ch = channel.fromPath(params.input)
            .splitCsv(header: true)
            .map { row -> file(row.reads_bam) }

    // Loading the file paths for the accessory files (reference and intervals)
    // These are not channels.
    // We are simply converting the parameter values into Nextflow Path objects that can be supplied to a process.
    ref_file = file(params.reference)
    ref_index_file = file(params.reference_index)
    ref_dict_file = file(params.reference_dict)
    intervals_file = file(params.intervals)



    // Create index file for input BAM file
    SAMTOOLS_INDEX(reads_ch)
    // Pass the BAM files in reads_ch to the SAMTOOLS_INDEX process
    // Each BAM is indexed using Samtools

    // to view what samples are being passed
    reads_ch.view() // to see what are the inputs
    SAMTOOLS_INDEX.out.view() // to see output of first process

    // Call variants from the indexed BAM file
    GATK_HAPLOTYPECALLER(
        SAMTOOLS_INDEX.out,
        ref_file,
        ref_index_file,
        ref_dict_file,
        intervals_file
    )
    // Pass the indexed BAM files, reference files and intervals to HaplotypeCaller
    // HaplotypeCaller produces a GVCF for each sample


    all_gvcfs_ch = GATK_HAPLOTYPECALLER.out.vcf.collect()
    // Collect all per-sample GVCF files into a single list/channel
    // so they can be supplied together to the joint genotyping process.

    all_idxs_ch = GATK_HAPLOTYPECALLER.out.idx.collect()
    // Collect all GVCF index files so they can be supplied together
    // with the corresponding GVCFs.

    // Combine GVCFs into a GenomicsDB data store and apply joint genotyping
    GATK_JOINTGENOTYPING(
        all_gvcfs_ch,
        all_idxs_ch,
        intervals_file,
        params.cohort_name,
        ref_file,
        ref_index_file,
        ref_dict_file
    )

    // Pass the collected GVCFs, their indexes, intervals, cohort name and
    // reference files to the joint genotyping process.
    // GenomicsDBImport stores the GVCF information in GenomicsDB,
    // and GenotypeGVCFs produces the final cohort-level VCF.

    // Call processes

    publish:
    // Declare the outputs that should be made available after the pipeline finishes.

    indexed_bam = SAMTOOLS_INDEX.out
    gvcf = GATK_HAPLOTYPECALLER.out.vcf
    gvcf_idx = GATK_HAPLOTYPECALLER.out.idx
    joint_vcf = GATK_JOINTGENOTYPING.out.vcf
    joint_vcf_idx = GATK_JOINTGENOTYPING.out.idx
}

output {
    // Configure where the published outputs will be placed.
    indexed_bam {
        path 'indexed_bam'
    }
    gvcf {
        path 'gvcf'
    }
    gvcf_idx {
        path 'gvcf'
    }
    joint_vcf {
        path '.'
    }
    joint_vcf_idx {
        path '.'
    }
}
