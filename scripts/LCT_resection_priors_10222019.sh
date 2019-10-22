#!/bin/bash
#
# This file registers the post resection image to the Nick Oasis template, transforms the resection roi to template space, and generates a
# template mask with the resection zone removed. Subsequently it runs the antsLongitudinalCorticalThickness pipeline.
#
# Usage:    ./scripts/LCT_resection_priors.sh pat15 T1W3D-0001_pre_pat15.nii T1W3D-0001_post_pat15b.nii
#           ./scripts/LCT_resection_priors.sh 14_w 14_w_preop.nii.gz 14_w_postop.nii.gz 
# 
#   pat04 - HUP subject ID
#   15_e - VU subject ID
#
# Data:
# HUP subjects (17)
# subs = ['14_w';'15_e';'20_l';'22_m';'23_r';'24_c';'25_f';'26_k';'27_m';'28_d';'29_w';'30_m';'31_h';'33_s';'40_f';'41_h';'42_m';];
# VU Subjects (23)
# subs = ['02'; '03'; '04'; '05'; '06'; '07'; '08'; '09'; '11'; '13'; '14'; '15'; '18'; '20'; '21'; '22'; '23'; '24'; '25'; '26'; '27'; '30'; '32'];
#
# Thomas Campbell Arnold
# tcarnold@seas.upenn.edu
# 5/23/2019
# 10/22/2019 - used manually edited versions of resections

DATA_DIR=./data/${1}/
TEMPLATE_DIR=./tools/OasisTemplate/
ANALYSIS_DIR=./analysis/${1}/

# set image names to variable
name=$(echo "$2" | cut -f 1 -d '.')
pre=${name}
name=$(echo "$3" | cut -f 1 -d '.')
post=${name}

# get pre and post folder names
prefolder=$(echo ./analysis/"${1}"/"${pre}"*/)
postfolder=$(echo ./analysis/"${1}"/"${post}"*/)

# setup output directory
OUT_DIR=./analysis/${1}/
mkdir $OUT_DIR
OUT_DIR=./analysis/${1}/LCT_manual/
mkdir $OUT_DIR

# transform post-resection roi to SST
#IMG=./analysis/${1}/resection_affine/resection_mask_postprocessed.nii.gz
IMG=./tmp/resections_manual/${1}/resection_mask_postprocessed.nii.gz
antsApplyTransforms \
-d 3 \
-i ${IMG} \
-o ${OUT_DIR}post2SST_resection_mask.nii.gz \
-t ${postfolder}${post}SubjectToTemplate0GenericAffine.mat \
-t ${postfolder}${post}SubjectToTemplate1Warp.nii.gz \
-n NearestNeighbor \
-r ${ANALYSIS_DIR}SingleSubjectTemplate/T_template0.nii.gz

# remove resection roi from brain-mask
matlab -nodisplay -nosplash -r "addpath(genpath(pwd)); resection_priors_10222019('./analysis/"${1}"/'); exit;"

# reorient images
for f in ${OUT_DIR}*
do
c3d ${f} -orient RPI -o ${f}
done

# using longitudinal cortical thickness
# get number of files (used to determine number of cores to use)
img_N=$(ls -l ${DATA_DIR}*.nii* | wc -l)

antsLongitudinalCorticalThickness.sh -d 3 \
              -c 2 \
              -j ${img_N} \
              -e ${ANALYSIS_DIR}SingleSubjectTemplate/T_template0.nii.gz \
              -f ${OUT_DIR}template_resection_probability_masked.nii \
              -m ${OUT_DIR}template_resection_masked.nii \
              -p ${OUT_DIR}resectionPriors%d.nii \
              -o ${OUT_DIR}LCT_ \
              ${DATA_DIR}*.nii* 