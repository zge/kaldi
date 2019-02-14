#!/bin/bash
set -e

. ./cmd.sh
. ./path.sh
. ./utils/parse_options.sh

LMEXT=ckws_masa_keyword
dir=exp/nnet2_online

# 1st exp

EXP=exp01
test=cKWS_masa

graph_dir=exp/tri5a/graph_${LMEXT}
data_dir=data/$test
decode_dir=${dir}/${EXP}/decode_${test}_${LMEXT}

steps/online/nnet2/decode.sh --config conf/decode.config --cmd "$decode_cmd" --nj 1 --stage 0 \
    ${graph_dir} ${data_dir} ${decode_dir}

# 2nd exp

EXP=exp02
test=right_rand_1000_a

graph_dir=exp/tri5a/graph_${LMEXT}
data_dir=${HOME}/Work/Projects/ckws-kaldi/datasets/$test
decode_dir=${dir}/${EXP}/decode_${test}_${LMEXT}

steps/online/nnet2/decode.sh --config conf/decode.config --cmd "$decode_cmd" --nj 1 --stage 0 \
    ${graph_dir} ${data_dir} ${decode_dir}

# 3rd exp
EXP=exp03
test=isolated_utts

graph_dir=exp/tri5a/graph_${LMEXT}
data_dir=${HOME}/Work/Projects/ckws-kaldi/datasets/$test
decode_dir=${dir}/${EXP}/decode_${test}_${LMEXT}

steps/online/nnet2/decode.sh --config conf/decode.config --cmd "$decode_cmd" --nj 1 --stage 0 \
    ${graph_dir} ${data_dir} ${decode_dir}

# 4th exp
EXP=exp04
test=both_rand_1000_a_utterance_10

graph_dir=exp/tri5a/graph_${LMEXT}
data_dir=${HOME}/Work/Projects/ckws-kaldi/datasets/$test
decode_dir=${dir}/${EXP}/decode_${test}_${LMEXT}

steps/online/nnet2/decode.sh --config conf/decode.config --cmd "$decode_cmd" --nj 1 --stage 0 \
    ${graph_dir} ${data_dir} ${decode_dir}

#lattice-align-words ${graph_dir}/phones/word_boundary.int exp/tri5a/final.mdl "ark:zcat ${decode_dir}/lat.1.gz |" ark,t:${decode_dir}/aligned.1.txt

# output aligned lattice, where each line contains start/end state, decoded word, LM cost, graph cost, transition IDs 
lattice-align-words ${graph_dir}/phones/word_boundary.int exp/tri5a/final.mdl "ark:zcat ${decode_dir}/lat.1.gz |" ark,t:- | utils/int2sym.pl -f 3 ${graph_dir}/words.txt > ${decode_dir}/aligned.1.txt

# this gives the word boundary info for the decoded word
lattice-1best --lm-scale=12 --word-ins-penalty=0 \
              "ark:zcat ${decode_dir}/lat.1.gz |" ark:- |
lattice-align-words ${graph_dir}/phones/word_boundary.int \
              exp/tri5a/final.mdl \
              ark:- ark:- |
nbest-to-ctm ark:- - |
utils/int2sym.pl -f 5 ${graph_dir}/words.txt > ${decode_dir}/transcript.ctm

# decoding prob for all segments become 1 after do the 1best lattice first
#lattice-1best --lm-scale=12 --word-ins-penalty=0 \
#              "ark:zcat ${decode_dir}/lat.1.gz |" ark:- |
#lattice-to-ctm-conf --acoustic-scale=0.1 --lm-scale=12 --decode-mbr=false ark:- ${decode_dir}/1.ctm

# this show the decodign prob are very high for all the decoded words
lattice-to-ctm-conf --acoustic-scale=0.1 --lm-scale=12 --decode-mbr=false "ark:zcat ${decode_dir}/lat.1.gz |" ${decode_dir}/1.ctm
