#!/bin/bash
#
# decode using big LM with selected keywords (both positive and negative data)
# note: LMs from this script have different naming convension compared with the LMs in
# run_eval_exp3.sh
#
# Zhenhao Ge, 2019-03-08

if [ $# \< 1 ]; then
  echo "Usage: run_eval_exp3.sh <vsize> <rep_factor> <kwset> <EXP> <DEXP> <testset> <num-jobs>(opt)"
  echo "  <vsize>: vocab-size, e.g. {2k, 10k, 50k}"
  echo "  <rep_factor>: repitition factor, every selected keywords will be repeated <rep_factor>X6400 times"
  echo "    e.g. {100, 500, 5000}"
  echo "  <kwset>: keyword set index, e.g. {1..5}"
  echo "  <EXP>: experiment version index, e.g. exp{01-07}"
  echo "  <DEXP>: dataset version index, e.g. exp{01-05}"
  echo "  <testset>: e.g. all_rand_6000_a_6000"
  echo "  <num-jobs>: e.g. {4,8,16} <= ncpus"
  echo "e.g. run_eval_exp4.sh 50k 500 1 07 05 all_rand_6000_a_6000_kw5_set1 16"
  exit 1
fi

. ./cmd.sh
. ./path.sh

vsize=$1 # adjustable: {2k, 10k, 50k}
rep_factor=$2 # adjustable: {100, 500, 5000}
kwset=$3 # adjustable: {1..5}
EXT=v${vsize}-w${rep_factor}-s${kwset}
LMEXT=lang_${EXT}_general_fisher_swbd_spsp_cnsl_1gram 
IFS='_' read -r -a parts <<< "$LMEXT"
dir=exp/nnet2_online
graph_dir=exp/tri5a/graph_${LMEXT}
echo "graph dir: ${graph_dir}"

EXP=exp$4 # eval exp version (05: positive only, 06: original, 07: normalized, silence-inserted)
DEXP=exp$5 # data version (03: original, 04: normalized, 05: silence-inserted)
test=$6 # small or regular
nj=${7:-"16"}

# decode the positive/nagative combined dataset
echo "decoding ${test} ..."
data_dir=${HOME}/Work/Projects/ckws-kaldi/datasets/${DEXP}/$test
decode_dir=${dir}/${EXP}/decode_${test}_${parts[1]}
echo "data dir: ${data_dir}"
echo "decode dir: ${decode_dir}"

# run decoder
steps/online/nnet2/decode.sh \
  --config conf/decode.config \
  --cmd "$decode_cmd" \
  --nj ${nj} \
  --stage 0 \
  ${graph_dir} ${data_dir} ${decode_dir}





