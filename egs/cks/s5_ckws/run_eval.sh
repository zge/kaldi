#!/bin/bash
set -e

. ./cmd.sh
. ./path.sh
. ./utils/parse_options.sh

LMEXT=ckws_masa_keyword

EXP=exp01

dir=exp/nnet2_online

for test in cKWS_masa; do
(
    steps/online/nnet2/decode.sh --config conf/decode.config --cmd "$decode_cmd" --nj 1 --stage 0 \
            exp/tri5a/graph_${LMEXT} data/$test ${dir}/${EXP}/decode_${test}_${LMEXT} || exit 1;
)&
done


