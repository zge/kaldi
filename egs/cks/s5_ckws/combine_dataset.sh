#!/bin/bash
#
# combine datasets, e.g. from left/right/both cases
#
# Zhenhao Ge, 2019-02-27

dexp="exp05"
dir="${HOME}/Work/Projects/ckws-kaldi/datasets/${dexp}"
idx=$1

# case 1 (combine left/right/both to positive)
#tag="rand_1000_a_utterance_1000"
#src_dirs=$(ls -d ${dir}/*_${tag})
#n=$(wc -w <<< ${src_dirs}) # num of cases (e.g. 3)
#tag2=$(echo $tag | sed "s/1000/${n}X1000/g")
#dest_dir=${dir}/positive_${tag2}

# case 2 (combine left/right/both and negative to all)
nkws=5
set_tag=set${idx} # set{1..5}
pos_dirs=$(ls -d ${dir}/{left,right,both}_rand_1000_a_1000_kw${nkws}_${set_tag})
neg_dir=${dir}/negative_rand_3000_a_3000
dest_dir=${dir}/all_rand_6000_a_6000_kw${nkws}_${set_tag}

# combine datasets
if [ ! -z "${src_dirs}" ]; then
  echo "case 1: combine left/right/both to positive ..."
  ./utils/combine_data.sh ${dest_dir} ${src_dirs}
else
  echo "case 2: combine left/right/both and negative to all ..."
  ./utils/combine_data.sh ${dest_dir} ${pos_dirs} ${neg_dir}
fi

# fix utt2spk myself
echo "fixing utt2spk order ..."
cat ${dest_dir}/utt2spk | sort > ${dest_dir}/utt2spk_sorted
mv ${dest_dir}/utt2spk_sorted ${dest_dir}/utt2spk
