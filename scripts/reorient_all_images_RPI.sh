#!/bin/bash
#
# This file reorients all nifti images in the data folder to RPI orientation
#
# Thomas Campbell Arnold
# tcarnold@seas.upenn.edu
# 5/23/2019

DATA_DIR=./data/

for SUB in ${DATA_DIR}*
do
cd ${SUB}
echo ${SUB}
for f in *.ni*
do
c3d $f -orient RPI -o $f
done
cd ..
done

