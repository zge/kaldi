#!/bin/bash
. ./cmd.sh
. ./path.sh

stage=$1

DATA=data

VOCAB=50k
VOCABSIZE=`echo $VOCAB | sed -e 's/k$/000/g'`

lmtool=srilm
order_lm=1
tgmin=${order_lm}gram-mincount

IDX=001

EXP=exp
EXT=ext${IDX}.$VOCAB

general=general_fisher_swbd_spsp_cnsl
GNRL_TXT=${DATA}/local/lm/${general}.train.txt
DEV_TXT=${DATA}/local/lm/${general}.dev.txt

SRILM=../../../kaldi-trunk/tools/srilm/bin/i686-m64

if [[ $stage -le -2 ]]; then
    dir=${DATA}/local/dict_${EXT}
    echo "dir=$dir"
    PROC_TXT=${GNRL_TXT}

    # Initial Preparation
    rm -rf $dir
    mkdir -p $dir
    for f in lexicon.txt silence_phones.txt optional_silence.txt nonsilence_phones.txt; do
        [ ! -f ${DATA}/local/dict/$f ] && echo "$0: no such file $f" && exit 1;
        cp ${DATA}/local/dict/$f ${dir}/$f
    done
    cp $dir/lexicon.txt $dir/lexicon.org.txt

		# hifreq_words 
		cat $DATA/local/lm/word.counts | sort -r -k1 | awk '{print $2}' | head -$VOCABSIZE |\
		grep -vE '\!|\@|\#|\$|\"|\&|\%|\^|\&|\*|\(|\)|\?|\_|\-|\,|\-|\:' | grep -v '\.period' | sort | uniq >$dir/hifreq_words.$VOCAB
		
    # Find lexicon for hifreq_words to make new lexicon
    cat $dir/lexicon.org.txt |\
    awk -v wrd=$dir/hifreq_words.$VOCAB 'BEGIN{while((getline<wrd) >0){ seen[$1]=1; } }
      { if (seen[$1]) { print $0 } }' | sort | uniq > $dir/lexicon.txt
    
		# Generating L.fst
    utils/pssr_lang.sh ${DATA}/local/dict_${EXT} "<unk>" ${DATA}/local/lang_${EXT} ${DATA}/lang_${EXT}
fi


if [[ $stage -le -1 ]]; then
    cfg=01

		langdir=lang_${EXT}_${general}_${order_lm}gram
    dir=${DATA}/${langdir}
    cp -R ${DATA}/lang_${EXT} ${dir}

    mkdir -p $dir/general/$tgmin
    GNRL_UNK_TXT=$dir/general.no_oov.txt
    GNRL_LM=$dir/general/$tgmin/lm_unpruned.gz
    GNRL_VOC=$dir/general/$tgmin/lm_unpruned.voc
    GNRL_EFF=$dir/general/$tgmin/lm_unpruned.effcounts

		cat ${GNRL_TXT} | awk -v lex=${DATA}/local/dict_${EXT}/lexicon.txt 'BEGIN{while((getline<lex) >0){ seen[$1]=1; } }
			{for(n=1; n<=NF;n++) {  if (seen[$n]) { printf("%s ", $n); } else {printf("<unk> ");} } printf("\n");}' \
			> ${GNRL_UNK_TXT} || exit 1;

    echo "Generating ngram using $lmtool"
		ngram-count -text ${GNRL_UNK_TXT} -order ${order_lm} -unk \
			-map-unk "<unk>" -kndiscount -interpolate -lm ${GNRL_LM}
		$SRILM/ngram -order ${order_lm} -unk \
				-lm      $GNRL_LM \
				-ppl $DEV_TXT \
				-debug 1 2>&1 >$dir/${general}.cfg${cfg}.log

		srilm_opts="-subset -prune-lowprobs -unk -tolower -order ${lm_order}"
		utils/format_lm_sri.sh --srilm-opts "$srilm_opts" \
			${DATA}/lang_${EXT} ${GNRL_LM} ${DATA}/${langdir}
    
		echo "Generating graph : ${graph_dir}"
    graph_dir=${EXP}/tri5a/graph_${langdir}
		rm -rf $graph_dir/*
		utils/mkgraph.sh ${DATA}/${langdir} ${EXP}/tri5a $graph_dir

fi
