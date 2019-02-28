#!/bin/bash
#
# combine datasets, e.g. from left/right/both cases
#
# Zhenhao Ge, 2019-02-27

dir=${HOME}/Work/Projects/ckws-kaldi/datasets/exp02

tag="rand_1000_a_utterance_1000"
src_dirs=$(ls -d ${dir}/*_${tag})
n=$(wc -w <<< ${src_dirs}) # num of cases (e.g. 3)
tag2=$(echo $tag | sed "s/1000/${n}X1000/g")
dest_dir=${dir}/"positive_${tag2}"

# combine datasets
./utils/combine_data.sh ${dest_dir} ${src_dirs} 

# fix utt2spk myself
cat ${dest_dir}/utt2spk | sort > ${dest_dir}/utt2spk_sorted
mv ${dest_dir}/utt2spk_sorted ${dest_dir}/utt2spk
