#!/bin/bash
#
# decode using big LM with 15 keywords (both positive and negative data) 
#
# Zhenhao Ge, 2019-02-28

. ./cmd.sh
. ./path.sh

IDX=001 # adjustable: 001: 500 reps; 002: 5000 reps
LMEXT=lang_ext${IDX}.50k_general_fisher_swbd_spsp_cnsl_1gram # adjustable: 2k, 10k, 50k
IFS='_' read -r -a parts <<< "$LMEXT"
dir=exp/nnet2_online
graph_dir=exp/tri5a/graph_${LMEXT}

EXP=exp07 # eval exp version #
DEXP=exp03 # data version

## case 1: decode the positive/negative datasets respectively
#test1=positive_rand_3X1000_a_3X1000 # positive
#test2=negative_rand_3000_a_3000 # negative
#for test in ${test1} ${test2}; do
#  echo "decoding ${test} ..."
#  data_dir=${HOME}/Work/Projects/ckws-kaldi/datasets/${DEXP}/$test
#  decode_dir=${dir}/${EXP}/decode_${test}_${parts[1]}
#  steps/online/nnet2/decode.sh \
#    --config conf/decode.config \
#    --cmd "$decode_cmd" \
#    --nj 4 \
#    --stage 0 \
#    ${graph_dir} ${data_dir} ${decode_dir}
#done

# case 2: decode the positive/nagative combined dataset
test=all_rand_6000_a_600
echo "decoding ${test} ..."
data_dir=${HOME}/Work/Projects/ckws-kaldi/datasets/${DEXP}/$test
decode_dir=${dir}/${EXP}/decode_${test}_${parts[1]}
steps/online/nnet2/decode.sh \
  --config conf/decode.config \
  --cmd "$decode_cmd" \
  --nj 16 \
  --stage 0 \
  ${graph_dir} ${data_dir} ${decode_dir}





