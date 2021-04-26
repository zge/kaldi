#!/bin/bash
#
# decode using big LM with 15 keywords (both positive and negative data) 
#
# Zhenhao Ge, 2019-02-28

if [ $# \< 1 ]; then
  echo "Usage: run_eval_exp3.sh <IDX> <vsize> <EXP> <DEXP> <SET> <testset> <num-jobs>(opt)"
  echo "  <IDX>: #reps version index, e.g. {001, 002, 003}"
  echo "  <vsize>: vocab-size, e.g. {2k, 10k, 50k}"
  echo "  <EXP>: experiment version index, e.g. exp{01-07}"
  echo "  <DEXP>: dataset version index, e.g. exp{01-05}"
  echo "  <SET>: keyword appendix, e.g. kw15"
  echo "    (used to differenciate 'silence-inserted' version with 'normalized' version in EXP:exp07)"
  echo "  <testset>: e.g. all_rand_6000_a_6000"
  echo "  <num-jobs>: e.g. {4,8,16} <= ncpus"
  echo "e.g. run_eval_exp3.sh 001 50k exp07 exp05 kw15 all_rand_6000_a_6000 16"
  exit 1
fi

. ./cmd.sh
. ./path.sh

IDX=$1 # adjustable: 001: 500 reps; 002: 5000 reps; 003: 100 reps
vsize=$2 # adjustable: 2k, 10k, 50k
LMEXT=lang_ext${IDX}.${vsize}_general_fisher_swbd_spsp_cnsl_1gram
IFS='_' read -r -a parts <<< "$LMEXT"
dir=exp/nnet2_online
graph_dir=exp/tri5a/graph_${LMEXT}

EXP=$3 # eval exp version (05: positive only, 06: original, 07: normalized, silence-inserted)
DEXP=$4 # data version (03: original, 04: normalized, 05: silence-inserted)
SET=$5
test=$6 # small or regular
nj=${7:-"16"}

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
echo "decoding ${test} ..."
data_dir=${HOME}/Work/Projects/ckws-kaldi/datasets/${DEXP}/$test
decode_dir=${dir}/${EXP}/decode_${test}_${parts[1]}_${SET}
steps/online/nnet2/decode.sh \
  --config conf/decode.config \
  --cmd "$decode_cmd" \
  --nj ${nj} \
  --stage 0 \
  ${graph_dir} ${data_dir} ${decode_dir}





