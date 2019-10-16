#!/bin/bash
#
# This code warps an atlas to the Nick Oasis template space.
#
# Usage: atlas2NickOasis.sh AAL116.nii
#
#
# Thomas Campbell Arnold 
# tcarnold@seas.upenn.edu
# 
# 5/17/2019 - created
# 6/5/2019 - seperated into atlas2NickOasis.sh and atlas2native.sh

TEMPLATE_DIR=./tools/OasisTemplate/
ATLAS_DIR=./tools/atlases/

# name of atlas being used
IMG=$(echo "$1" | cut -f 1 -d '.')

# Registration of MNI-Atlas to Nick Oasis templat
antsRegistration \
--dimensionality 3 \
--float 0 \
--output ${ATLAS_DIR}atlas2template_${IMG} \
--interpolation Linear \
--use-histogram-matching 0 \
--initial-moving-transform [${TEMPLATE_DIR}T_template0.nii.gz,${ATLAS_DIR}MNI_T1.nii,1] \
--transform Rigid[0.1] \
--metric MI[${TEMPLATE_DIR}T_template0.nii.gz,${ATLAS_DIR}MNI_T1.nii,1,32,Regular,0.25] \
--convergence [1000x500x250x100,1e-6,10] \
--shrink-factors 8x4x2x1 \
--smoothing-sigmas 3x2x1x0vox \
--transform Affine[0.1] \
--metric MI[${TEMPLATE_DIR}T_template0.nii.gz,${ATLAS_DIR}MNI_T1.nii,1,32,Regular,0.25] \
--convergence [1000x500x250x100,1e-6,10] \
--shrink-factors 8x4x2x1 \
--smoothing-sigmas 3x2x1x0vox \
--transform SyN[0.1,3,0] \
--metric CC[${TEMPLATE_DIR}T_template0.nii.gz,${ATLAS_DIR}MNI_T1.nii,1,4] \
--convergence [100x70x50x20,1e-6,10] \
--shrink-factors 8x4x2x1 \
--smoothing-sigmas 3x2x1x0vox

# transform Atlas to template space
antsApplyTransforms \
-d 3 \
-i ${ATLAS_DIR}MNI_T1.nii ${ATLAS_DIR}${1} \
-o ${ATLAS_DIR}atlas2template_${1} \
-t ${ATLAS_DIR}atlas2template_${IMG}1Warp.nii.gz \
-t ${ATLAS_DIR}atlas2template_${IMG}0GenericAffine.mat \
-r ${TEMPLATE_DIR}T_template0.nii.gz \
-n NearestNeighbor
