#!/bin/bash
#SBATCH --ntasks=10              #Requesting 10 cores
#SBATCH --mem-per-cpu=8G         #Requesting 8 Gb memory per core
#SBATCH --time=120:00:00          #Requesting 120 hours of run-time
#SBATCH --mail-type=FAIL         #Email if the job fail
#SBATCH --mail-user=anton.lavrinienko@hest.ethz.ch      #Email address


source activate qiime2-amplicon-2024.2

path="/cluster/scratch/alavrinienko/FUNGUIDE"
project_id="PRJEB42375"
fwprim="CTTGGTCATTTAGAGGAAGTAA"
revcomp="GCATCGATGAAGAACGCAGC"

#######################################################
echo "Anton Lavrinienko, FUNGUIDE project, 17 May 2024"
echo "$(date) start ${SLURM_JOB_ID}/${project_id}"
#######################################################


qiime demux summarize \
    --i-data "${path}/${project_id}/raw-data/${project_id}_final_raw_reads.qza" \
    --o-visualization "${path}/${project_id}/raw-data/${project_id}_final_raw_reads.qzv"


#quality filter based on sequence quality scores
mkdir -p "${path}/${project_id}/demux/quality_filter"

qiime quality-filter q-score \
    --i-demux "${path}/${project_id}/raw-data/${project_id}_final_raw_reads.qza" \
    --p-min-quality 20 \
    --p-min-length-fraction 0 \
    --o-filtered-sequences "${path}/${project_id}/demux/quality_filter/${project_id}_reads_quality_filtered.qza" \
    --o-filter-stats "${path}/${project_id}/demux/quality_filter/${project_id}_reads_quality_filter_stats.qza"

#visualizations
qiime metadata tabulate \
    --m-input-file "${path}/${project_id}/demux/quality_filter/${project_id}_reads_quality_filter_stats.qza" \
    --o-visualization "${path}/${project_id}/demux/quality_filter/${project_id}_reads_quality_filter_stats.qzv"

qiime demux summarize \
    --i-data "${path}/${project_id}/demux/quality_filter/${project_id}_reads_quality_filtered.qza" \
    --o-visualization "${path}/${project_id}/demux/quality_filter/${project_id}_reads_quality_filtered.qzv"

#cutadapt: 3 steps
mkdir -p "${path}/${project_id}/demux/cutadapt"

#cutadapt: trimming of forward primer
qiime cutadapt trim-single \
    --i-demultiplexed-sequences "${path}/${project_id}/demux/quality_filter/${project_id}_reads_quality_filtered.qza" \
    --p-front "${fwprim}" \
    --p-error-rate 0.2 \
    --p-overlap 8 \
    --o-trimmed-sequences "${path}/${project_id}/demux/cutadapt/${project_id}_fwprim_trimmed.qza" \
    --verbose | tee "${path}/${project_id}/demux/cutadapt/${project_id}_fwprim_log.txt"


#cutadapt: trimming of reverse complement of forward primer
qiime cutadapt trim-single \
    --i-demultiplexed-sequences "${path}/${project_id}/demux/cutadapt/${project_id}_fwprim_trimmed.qza" \
    --p-adapter "${revcomp}" \
    --p-error-rate 0.2 \
    --p-overlap 16 \
    --o-trimmed-sequences "${path}/${project_id}/demux/cutadapt/${project_id}_revcomp_fwprim_trimmed.qza" \
    --verbose | tee "${path}/${project_id}/demux/cutadapt/${project_id}_revcomp_log.txt"


#cutadapt: adapter trimming
qiime cutadapt trim-single \
    --i-demultiplexed-sequences "${path}/${project_id}/demux/cutadapt/${project_id}_revcomp_fwprim_trimmed.qza" \
    --p-adapter AGATCGGAAGAGC \
    --p-error-rate 0.2 \
    --p-overlap 13 \
    --p-minimum-length 50 \
    --o-trimmed-sequences "${path}/${project_id}/demux/cutadapt/${project_id}_final_trimmed.qza" \
    --verbose | tee "${path}/${project_id}/demux/cutadapt/${project_id}_adapter_log.txt"

#visualization
qiime demux summarize \
    --i-data "${path}/${project_id}/demux/cutadapt/${project_id}_final_trimmed.qza" \
    --o-visualization "${path}/${project_id}/demux/cutadapt/${project_id}_final_trimmed.qzv"


#denoising with dada2
mkdir -p "${path}/${project_id}/dada2"

qiime dada2 denoise-single \
    --i-demultiplexed-seqs "${path}/${project_id}/demux/cutadapt/${project_id}_final_trimmed.qza" \
    --p-trunc-len 0 \
    --o-table "${path}/${project_id}/dada2/${project_id}_dada2_feature_table.qza" \
    --o-representative-sequences "${path}/${project_id}/dada2/${project_id}_dada2_rep_seqs.qza" \
    --o-denoising-stats "${path}/${project_id}/dada2/${project_id}_dada2_stats.qza"

#visualizations
qiime feature-table summarize \
    --i-table "${path}/${project_id}/dada2/${project_id}_dada2_feature_table.qza" \
    --o-visualization "${path}/${project_id}/dada2/${project_id}_dada2_feature_table.qzv"

qiime feature-table tabulate-seqs \
    --i-data "${path}/${project_id}/dada2/${project_id}_dada2_rep_seqs.qza" \
    --o-visualization "${path}/${project_id}/dada2/${project_id}_dada2_rep_seqs.qzv"

qiime metadata tabulate \
    --m-input-file "${path}/${project_id}/dada2/${project_id}_dada2_stats.qza" \
    --o-visualization "${path}/${project_id}/dada2/${project_id}_dada2_stats.qzv"

# filter features
mkdir -p "${path}/${project_id}/dada2/filter10"

#filter features from table
qiime feature-table filter-features \
    --i-table "${path}/${project_id}/dada2/${project_id}_dada2_feature_table.qza" \
    --p-min-frequency 10 \
    --o-filtered-table "${path}/${project_id}/dada2/filter10/${project_id}_filter10_feature_table.qza"

#fileter features from sequences
qiime feature-table filter-seqs \
    --i-data "${path}/${project_id}/dada2/${project_id}_dada2_rep_seqs.qza" \
    --i-table "${path}/${project_id}/dada2/filter10/${project_id}_filter10_feature_table.qza" \
    --o-filtered-data "${path}/${project_id}/dada2/filter10/${project_id}_filter10_rep_seqs.qza"

#visualizations
qiime feature-table summarize \
    --i-table "${path}/${project_id}/dada2/filter10/${project_id}_filter10_feature_table.qza" \
    --o-visualization "${path}/${project_id}/dada2/filter10/${project_id}_filter10_feature_table.qzv"

qiime feature-table tabulate-seqs \
    --i-data "${path}/${project_id}/dada2/filter10/${project_id}_filter10_rep_seqs.qza" \
    --o-visualization "${path}/${project_id}/dada2/filter10/${project_id}_filter10_rep_seqs.qzv"


##########################
##Get a summary of the job
myjobs -j ${SLURM_JOB_ID}
##########################