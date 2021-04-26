#!/bin/bash
#
# decode using big LM with 15 keywords (positive data only)
#
# Zhenhao Ge, 2019-02-22

. ./cmd.sh
. ./path.sh

IDX=002 # adjustable: 001: 500 reps; 002: 5000 reps
LMEXT=lang_ext${IDX}.2k_general_fisher_swbd_spsp_cnsl_1gram # adjustable: 2k, 10k, 50k
IFS='_' read -r -a parts <<< "$LMEXT"
dir=exp/nnet2_online

EXP=exp05
test=both_rand_1000_a_utterance_1000 # adjustable: left, right, both

graph_dir=exp/tri5a/graph_${LMEXT}
data_dir=${HOME}/Work/Projects/ckws-kaldi/datasets/$test
decode_dir=${dir}/${EXP}/decode_${test}_${parts[1]}

#scoring_opts=\"--cmd run.pl --stage 0 --min_lmwt 5 --max_lmwt 40 --reverse false\"
steps/online/nnet2/decode.sh --config conf/decode.config --cmd "$decode_cmd" --nj 1 --stage 0 \
    ${graph_dir} ${data_dir} ${decode_dir}


