#!/bin/bash
#
# This file is used to generate a resection ROI using the output from SST generation.
#
# Usage:	resection_roi.sh pat04
#		resection_roi.sh 15_e
# 
#   pat04 - HUP subject ID
#   15_e - VU subject ID
#
# Command Template:
#	https://github.com/ANTsX/ANTs/wiki/Anatomy-of-an-antsRegistration-call
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

DATA_DIR=./data/${1}/
TEMPLATE_DIR=./tools/OasisTemplate/

# setup output directory
OUT_DIR=./analysis/${1}/resection/
mkdir $OUT_DIR

# Register OasisTempalte to SST
antsRegistration \
--dimensionality 3 \
--float 0 \
--output ${OUT_DIR}/oasis2SST_ \
--interpolation Linear \
--use-histogram-matching 0 \
--initial-moving-transform [./analysis/${1}/SingleSubjectTemplate/T_template0.nii.gz,${TEMPLATE_DIR}T_template0.nii.gz,1] \
--transform Rigid[0.1] \
--metric MI[./analysis/${1}/SingleSubjectTemplate/T_template0.nii.gz,${TEMPLATE_DIR}T_template0.nii.gz,1,32,Regular,0.25] \
--convergence [1000x500x250x100,1e-6,10] \
--shrink-factors 8x4x2x1 \
--smoothing-sigmas 3x2x1x0vox \
--transform Affine[0.1] \
--metric MI[./analysis/${1}/SingleSubjectTemplate/T_template0.nii.gz,${TEMPLATE_DIR}T_template0.nii.gz,1,32,Regular,0.25] \
--convergence [1000x500x250x100,1e-6,10] \
--shrink-factors 8x4x2x1 \
--smoothing-sigmas 3x2x1x0vox \
--transform SyN[0.1,3,0] \
--metric CC[./analysis/${1}/SingleSubjectTemplate/T_template0.nii.gz,${TEMPLATE_DIR}T_template0.nii.gz,1,4] \
--convergence [100x70x50x20,1e-6,10] \
--shrink-factors 8x4x2x1 \
--smoothing-sigmas 3x2x1x0vox \
--masks [./analysis/${1}/SingleSubjectTemplate/T_templateBrainExtractionMask.nii.gz]
