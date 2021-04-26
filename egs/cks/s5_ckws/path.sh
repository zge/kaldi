export PATH=$PWD/utils/:$PWD:$PATH
export LC_ALL=C
export LC_COLLATE=C
export KALDI_ROOT=`pwd`/../../..

PATH=${PATH}:$KALDI_ROOT/src/online2bin:$KALDI_ROOT/src/ivectorbin
PATH=${PATH}:$KALDI_ROOT/src/featbin:$KALDI_ROOT/src/latbin:$KALDI_ROOT/src/bin
PATH=${PATH}:$KALDI_ROOT/src/fstbin:$KALDI_ROOT/tools/openfst/bin:$KALDI_ROOT/src/lmbin
export PATH
