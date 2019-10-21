# This script is used to aggregate resection data for review

# temporary output location
mkdir tmp/resections/

# loop through HUP subjects
for sub in 14_w 15_e 20_l 22_m 23_r 24_c 25_f 26_k 27_m 28_d 29_w 30_m 31_h 33_s 40_f 41_h 42_m
do
	# copy all resection information
	mkdir tmp/resections/${sub}/
	cp -r analysis/${sub}/resection_affine/resection_mask.nii tmp/resections/${sub}/resection_mask.nii
	cp -r data/${sub}/${sub}_postop.nii.gz tmp/resections/${sub}/${sub}_postop.nii.gz
	cp -r analysis/${sub}/LCT_final_priors/${sub}_postop*/${sub}_postopBrainExtractionMask.nii.gz tmp/resections/${sub}/BrainExtractionMask.nii.gz
	# * deals with cases without all 3 images (pre, post, post2)
done

# loop through VU subjects
for sub in 02 03 04 05 06 07 08 09 11 13 14 15 18 20 21 22 23 24 25 26 27 30 32
do
	# copy all resection information
	mkdir tmp/resections/pat${sub}/
	cp -r analysis/pat${sub}/resection_affine/resection_mask.nii tmp/resections/pat${sub}/resection_mask.nii
	cp -r data/pat${sub}/T1W3D-0001_post_pat${sub}b.nii tmp/resections/pat${sub}/T1W3D-0001_post_pat${sub}b.nii
	cp -r analysis/pat${sub}/LCT_final_priors/T1W3D-0001_post_pat${sub}b*/T1W3D-0001_post_pat${sub}bBrainExtractionMask.nii.gz tmp/resections/pat${sub}/BrainExtractionMask.nii.gz
done

# zip for fast scp
zip -r tmp/resections_for_review tmp/resections/

# remove temporary folder
rm -r tmp/resections/