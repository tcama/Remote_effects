#!/bin/bash
#
# This code warps an atlas from Nick Oasis template space to the subjects native space.
#
# Usage: atlas2native.sh 14_w 14_w_preop.nii.gz AAL116.nii
#
#
# Thomas Campbell Arnold 
# tcarnold@seas.upenn.edu
#
# 5/17/2019 - created
# 6/5/2019 - seperated into atlas2NickOasis.sh and atlas2native.sh

# relevant paths
TEMPLATE_DIR=./tools/OasisTemplate/
ATLAS_DIR=./tools/atlases/
ANALYSIS_DIR=./analysis/${1}/
DATA_DIR=./data/${1}/

# get image name (used for LCT output foldercd name)
IMG=$(echo "$2" | cut -f 1 -d '.')
IMG_DIR=$(echo ./analysis/"${1}"/"${IMG}"*/)

# make output directory
OUT_DIR=${ANALYSIS_DIR}atlases/
mkdir ${OUT_DIR}

# Registration of Nick Oasis Template to Single Subject Template (SST)
antsRegistration \
--dimensionality 3 \
--float 0 \
--output ${OUT_DIR}template2SST_ \
--interpolation Linear \
--use-histogram-matching 0 \
--initial-moving-transform [${ANALYSIS_DIR}SingleSubjectTemplate/T_template0.nii.gz,${TEMPLATE_DIR}T_template0.nii.gz,1] \
--transform Rigid[0.1] \
--metric MI[${ANALYSIS_DIR}SingleSubjectTemplate/T_template0.nii.gz,${TEMPLATE_DIR}T_template0.nii.gz,1,32,Regular,0.25] \
--convergence [1000x500x250x100,1e-6,10] \
--shrink-factors 8x4x2x1 \
--smoothing-sigmas 3x2x1x0vox \
--transform Affine[0.1] \
--metric MI[${ANALYSIS_DIR}SingleSubjectTemplate/T_template0.nii.gz,${TEMPLATE_DIR}T_template0.nii.gz,1,32,Regular,0.25] \
--convergence [1000x500x250x100,1e-6,10] \
--shrink-factors 8x4x2x1 \
--smoothing-sigmas 3x2x1x0vox \
--transform SyN[0.1,3,0] \
--metric CC[${ANALYSIS_DIR}SingleSubjectTemplate/T_template0.nii.gz,${TEMPLATE_DIR}T_template0.nii.gz,1,4] \
--convergence [100x70x50x20,1e-6,10] \
--shrink-factors 8x4x2x1 \
--smoothing-sigmas 3x2x1x0vox
--masks [${ANALYSIS_DIR}SingleSubjectTemplate/BrainExtractionMask.nii.gz]

# transform Atlas to SST space
antsApplyTransforms \
-d 3 \
-i ${ATLAS_DIR}atlas2template_${3} \
-o ${OUT_DIR}template2SST_${3} \
-t ${OUT_DIR}template2SST_1Warp.nii.gz \
-t ${OUT_DIR}template2SST_0GenericAffine.mat \
-r ${ANALYSIS_DIR}SingleSubjectTemplate/T_template0.nii.gz \
-n NearestNeighbor

# transform SST_Atlas to native image space
antsApplyTransforms \
-d 3 \
-i ${OUT_DIR}template2SST_${3} \
-n NearestNeighbor \
-o ${OUT_DIR}${IMG}_${3} \
-t ${IMG_DIR}${IMG}TemplateToSubject0Warp.nii.gz \
-t ${IMG_DIR}${IMG}TemplateToSubject1GenericAffine.mat \
-r ${IMG_DIR}${IMG}CorticalThickness.nii.gz

