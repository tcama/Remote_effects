#!/bin/bash
#
# This file is used to process a single subject using the ANTs Longitudinal Cortical Thickness 
# pipeline with the ADNI normal Template. The output contains a SST, cortical thickness maps 
# (pre and post), relevant priors and transformations
#
# Usage:    ./scripts/LCT_ADNI.sh pat04 
#           ./scripts/LCT_ADNI.sh 14_w
# 
#   pat04 - HUP subject ID
#   14_w - VU subject ID
#
# Command Template:
# antsLongitudinalCorticalThickness.sh -d imageDimension
#              -e brainTemplate
#              -m brainExtractionProbabilityMask
#              -p brainSegmentationPriors
#              <OPTARGS>
#              -o outputPrefix
#              ${anatomicalImages[@]}
#
# Data:
# HUP subjects (17)
# subs = ['14_w';'15_e';'20_l';'22_m';'23_r';'24_c';'25_f';'26_k';'27_m';'28_d';'29_w';'30_m';'31_h';'33_s';'40_f';'41_h';'42_m';];
# VU Subjects (23)
# subs = ['02'; '03'; '04'; '05'; '06'; '07'; '08'; '09'; '11'; '13'; '14'; '15'; '18'; '20'; '21'; '22'; '23'; '24'; '25'; '26'; '27'; '30'; '32'];
#
# Thomas Campbell Arnold
# tcarnold@seas.upenn.edu
# 
# 5/23/2019 - created
# 10/3/2019 - updated for ADNI template, and renamed.
# 

DATA_DIR=./data/${1}/
TEMPLATE_DIR=./tools/ADNI_normal_atlas/

# setup output directory
OUT_DIR=./analysis/${1}/
mkdir $OUT_DIR

# get number of files (used to determine number of cores to use)
img_N=$(ls -l ${DATA_DIR}*.nii* | wc -l)

antsLongitudinalCorticalThickness.sh -d 3 \
              -c 2 \
              -j ${img_N} \
              -e ${TEMPLATE_DIR}T_template0.nii.gz \
              -m ${TEMPLATE_DIR}T_template0_BrainCerebellumProbabilityMask.nii.gz \
              -p ${TEMPLATE_DIR}Priors/priors%d.nii.gz \
              -f ${TEMPLATE_DIR}T_template0_BrainCerebellumExtractionMask.nii.gz \
              -o ${OUT_DIR} \
              ${DATA_DIR}*.nii* 
              