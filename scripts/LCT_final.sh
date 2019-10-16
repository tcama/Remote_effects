#!/bin/bash
#
# This file registers the post resection image to the Nick Oasis template, transforms the resection roi to template space, and generates a
# template mask with the resection zone removed. Subsequently it runs the antsLongitudinalCorticalThickness pipeline.
#
# Usage:    scripts/LCT_final.sh pat03 T1W3D-0001_pre_pat03.nii T1W3D-0001_post_pat03b.nii
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

DATA_DIR=./data/${1}/
TEMPLATE_DIR=./tools/OasisTemplate/
ANALYSIS_DIR=./analysis/${1}/

# set image names to variable
name=$(echo "$2" | cut -f 1 -d '.')
pre=${name}
name=$(echo "$3" | cut -f 1 -d '.')
post=${name}

# setup output directory
OUT_DIR=./analysis/${1}/
mkdir $OUT_DIR
OUT_DIR=./analysis/${1}/LCT_final/
mkdir $OUT_DIR

# transform post-resection roi to SST
IMG=./analysis/${1}/resection_affine/resection_mask.nii
antsApplyTransforms \
-d 3 \
-i ${IMG} \
-o ${OUT_DIR}post2SST_resection_mask.nii.gz \
-t ${ANALYSIS_DIR}${post}_0/${post}SubjectToTemplate0GenericAffine.mat \
-t ${ANALYSIS_DIR}${post}_0/${post}SubjectToTemplate1Warp.nii.gz \
-n NearestNeighbor \
-r ${ANALYSIS_DIR}SingleSubjectTemplate/T_template0.nii.gz

# remove resection roi from brain-mask
matlab -nodisplay -nosplash -r "cd scripts; resection_mask('/gdrive/public/USERS/tcarnold/Remote_effects/analysis/"${1}"/'); exit;"
 
#antsCorticalThickness.sh -d 3 \
#              -a ${DATA_DIR}${2} \
#              -e ${ANALYSIS_DIR}SingleSubjectTemplate/T_template0.nii.gz \
#              -m ${ANALYSIS_DIR}SingleSubjectTemplate/T_templateBrainExtractionMask.nii.gz \
#              -p ${ANALYSIS_DIR}SingleSubjectTemplate/T_templatePriors%d.nii.gz \
#              -o ${OUT_DIR}pre_
 
antsCorticalThickness.sh -d 3 \
              -a ${DATA_DIR}${2} \
              -e ${ANALYSIS_DIR}SingleSubjectTemplate/T_template0.nii.gz \
              -m ${OUT_DIR}/template_resection_masked.nii \
              -p ${ANALYSIS_DIR}SingleSubjectTemplate/T_templatePriors%d.nii.gz \
              -o ${OUT_DIR}pre_ 
 
#antsCorticalThickness.sh -d 3 \
#              -a ${DATA_DIR}${3} \
#              -e ${ANALYSIS_DIR}SingleSubjectTemplate/T_template0.nii.gz \
#              -m ${OUT_DIR}/template_resection_masked.nii \
#              -p ${ANALYSIS_DIR}SingleSubjectTemplate/T_templatePriors%d.nii.gz \
#              -o ${OUT_DIR}post_ 
              


## reorient template
#c3d ${TEMPLATE_DIR}T_template0.nii.gz -orient RPI -o ${OUT_DIR}T_template0.nii.gz
#
## Registration of pre-resection to post-resection
#mkdir ${OUT_DIR}/SST2template
#antsRegistration \
#--dimensionality 3 \
#--float 0 \
#--output ${OUT_DIR}/SST2template/SST2template_ \
#--interpolation Linear \
#--use-histogram-matching 0 \
#--initial-moving-transform [${OUT_DIR}T_template0.nii.gz,${ANALYSIS_DIR}SingleSubjectTemplate/T_template0.nii.gz,1] \
#--transform Rigid[0.1] \
#--metric MI[${OUT_DIR}T_template0.nii.gz,${ANALYSIS_DIR}SingleSubjectTemplate/T_template0.nii.gz,1,32,Regular,0.25] \
#--convergence [1000x500x250x100,1e-6,10] \
#--shrink-factors 8x4x2x1 \
#--smoothing-sigmas 3x2x1x0vox \
#--transform Affine[0.1] \
#--metric MI[${OUT_DIR}T_template0.nii.gz,${ANALYSIS_DIR}SingleSubjectTemplate/T_template0.nii.gz,1,32,Regular,0.25] \
#--convergence [1000x500x250x100,1e-6,10] \
#--shrink-factors 8x4x2x1 \
#--smoothing-sigmas 3x2x1x0vox \
#--transform SyN[0.1,3,0] \
#--metric CC[${OUT_DIR}T_template0.nii.gz,${ANALYSIS_DIR}SingleSubjectTemplate/T_template0.nii.gz,1,4] \
#--convergence [100x20x5x2,1e-6,10] \
#--shrink-factors 8x4x2x1 \
#--smoothing-sigmas 3x2x1x0vox 
##--masks [${ANALYSIS_DIR}SingleSubjectTemplate/T_templateBrainExtractionMask.nii.gz]
#
## transform post-resection roi to SST
#IMG=${OUT_DIR}post2SST_resection_mask.nii.gz
#antsApplyTransforms \
#-d 3 \
#-i ${IMG} \
#-o ${OUT_DIR}SST2template_resection_mask.nii.gz \
#-t ${OUT_DIR}/SST2template/SST2template_0GenericAffine.mat \
#-t ${OUT_DIR}/SST2template/SST2template_1Warp.nii.gz \
#-n NearestNeighbor \
#-r ${OUT_DIR}T_template0.nii.gz

#cd scripts
#matlab -nodisplay -nosplash -r "resection_roi_affine('/gdrive/public/USERS/tcarnold/Remote_effects/analysis/"${1}"/'); exit;"
