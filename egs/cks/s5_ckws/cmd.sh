# "queue.pl" uses qsub.  The options to it are
# options to qsub.  If you have GridEngine installed,
# change this to a queue you have access to.
# Otherwise, use "run.pl", which will run jobs locally
# (make sure your --num-jobs options are no more than
# the number of cpus on your machine.

export lo_cmd="run.pl"
export fe_cmd="queue.pl -l arch=*64"
export train_cmd="run.pl"
export train_cmd_2="run.pl"
export decode_cmd="run.pl"
export mkgraph_cmd="run.pl"
export big_memory_cmd="run.pl"
export cuda_cmd="run.pl"
export get_cmd="queue.pl --mem 4G"

