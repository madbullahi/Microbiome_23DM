#!/bin/bash
#SBATCH --job-name="SILVADATAbase"
#SBATCH --time=01:50:00
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=10G




BB_WORKDIR=$(mktemp -d /scratch/${USER}_${SLURM_JOBID}.XXXXXX)
export TMPDIR=${BB_WORKDIR}


set -e



module purge; module load bluebear
module load QIIME2/2021.11



qiime rescript get-silva-data \
--p-version '138' \
--p-target 'SSURef_NR99' \
--p-include-species-labels \
--o-silva-sequences silva-138-ssu-nr99-rna-seqs.qza \
--o-silva-taxonomy silva-138-ssu-nr99-tax.qza


qiime rescript reverse-transcribe \
--i-rna-sequences silva-138-ssu-nr99-rna-seqs.qza \
--o-dna-sequences silva-138-ssu-nr99-seqs.qza

qiime rescript cull-seqs \
--i-sequences silva-138-ssu-nr99-seqs.qza \
--o-clean-sequences silva-138-ssu-nr99-seqs-cleaned.qza

qiime rescript filter-seqs-length-by-taxon \
--i-sequences silva-138-ssu-nr99-seqs-cleaned.qza \
--i-taxonomy silva-138-ssu-nr99-tax.qza \
--p-labels Archaea Bacteria Eukaryota \
--p-min-lens 900 1200 1400 \
--o-filtered-seqs silva-138-ssu-nr99-seqs-filt.qza \
--o-discarded-seqs silva-138-ssu-nr99-seqs-discard.qza

qiime rescript dereplicate \
--i-sequences silva-138-ssu-nr99-seqs-filt.qza \
--i-taxa silva-138-ssu-nr99-tax.qza \
--p-rank-handles 'silva' \
--p-mode 'uniq' \
--o-dereplicated-sequences silva-138-ssu-nr99-seqs-derep-uniq.qza \
--o-dereplicated-taxa silva-138-ssu-nr99-tax-derep-uniq.qza

test -d ${BB_WORKDIR} && /bin/rm -rf ${BB_WORKDIR}