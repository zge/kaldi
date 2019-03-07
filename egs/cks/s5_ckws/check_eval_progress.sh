#!/bin/bash
#
# check the evaluation progress
# e.g. ./check_eval_progress.sh exp/nnet2_online/exp06/decode_all_rand_6000_a_6000_ext001.2k
#
# Zhenhao Ge, 2019-03-06

if [ $# \< 1 ]; then
  echo "Usage: check_eval_progress.sh <expdir>"
  echo "e.g. check_eval_progress.sh exp/nnet2_online/exp06/decode_all_rand_6000_a_6000_ext001.2k"
  exit 1
fi

expdir=$1
for f in $(ls ${expdir}/log/decode.*.log); do cat $f | grep "Decoded utterance" | wc -l >> tmp.txt; done
paste -sd+ tmp.txt | bc
rm tmp.txt
