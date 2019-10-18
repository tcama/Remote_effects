mkdir tmp/resections/

# loop through HUP subjects
for sub in 14_w 15_e 20_l 22_m 23_r 24_c 25_f 26_k 27_m 28_d 29_w 30_m 31_h 33_s 40_f 41_h 42_m
do
	cp -r analysis/${sub}/resection_affine tmp/resections/${sub}
done

# loop through VU subjects
for sub in 02 03 04 05 06 07 08 09 11 13 14 15 18 20 21 22 23 24 25 26 27 30 32
do
	cp -r analysis/pat${sub}/resection_affine tmp/resections/pat${sub}
done