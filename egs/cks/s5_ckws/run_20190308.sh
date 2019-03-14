#!/bin/bash
#
# Zhenhao Ge, 2019-03-08

# decode 5 kw5 sets (i.e. 50k,500,all_rand_6000_a_6000_kw5_set{1..5})
vsize=50k
rep_factor=500
exp=07
dexp=05
testbase=all_rand_6000_a_6000_kw5
nj=16
for idx in {1..5}; do
  ./run_eval_exp4.sh $vsize $rep_factor $idx $exp $dexp ${testbase}_set${idx} $nj &
done

# check progress
for idx in {1..5}; do
  dataset=all_rand_6000_a_6000_kw5_set${idx}
  n=$(cat ${HOME}/Work/Projects/ckws-kaldi/datasets/exp${dexp}/$dataset/wav.scp | wc -l)
  exp_folder=decode_all_rand_6000_a_6000_kw5_set${idx}_v${vsize}-w${rep_factor}-s${idx}
  expdir=exp/nnet2_online/exp${exp}/${exp_folder}
  echo -n "exp ${exp_folder} ($n): "
  ./check_eval_progress.sh $expdir
done

# check performance
cd ${HOME}/Work/Projects/ckws-kaldi

for idx in {1..5}; do
  lmext=v${vsize}-w${rep_factor}-s${idx}
  ./run_check_performance.sh ${testbase}_set${idx} keywords_set${idx}.txt $exp $dexp $lmext
done
  

