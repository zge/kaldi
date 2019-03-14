# CKWS evaluation

This directory contains part of scripts used in the project "[CKWS evaluation with Kaldi LVCSR](https://github.sie.sony.com/zge/ckws-kaldi)". The main repo contains 1) data preparation and 2) result collection, this repo contains 1) LM building and 2) decoding.

Please refer to the main repo for the project description, and here only the code base is covered.

## Code base

There are 4 major components of the codes created and used for this project:

1. Data Preparation (in the main repo)
2. LM Preparation (in the current repo)
3. LVCSR decoding with LM and data (in the current repo)
4. Result collection (in the main repo)

### Scripts for LM preparation

1. `build_lm.sh`: original LM build script in Kaldi;
2. `build_lm_jyoo.sh`: modified version from Jaekwon;
3. `build_lm_zge.sh`: modified version based on `build_lm_jyoo.sh`;
4. `build_lm_kws.sh`: modified version based on `build_lm_zge.sh` with the capability  to specify keywords.

### Scripts for LVCSR decoding

1. `run_eval.sh`: original decoding running script with one example, provided by Jaekwon;
2. `run_eval_exp1.sh`: collection of some initial decoding experiments using small keyword-only LMs, including:
   1. Reproducing the initial  CKWS evaluation on isolated keywords pronounced by Masa; 
   2. Decoding on isolated keyword extracted from synthesized speech;
   3. Decoding on isolated keyword from keyword-only recordings provided by Lakshmish;
   4. Decoding on synthesized utterances including keywords (also contains some word alignment commands).
3. `run_eval_exp2.sh`: decoding using big LM with 15 keywords (positive data only)
4. `run_eval_exp3.sh`: decoding using big LM with 15 keywords (both positive and negative data)
5. `run_eval_exp4.sh`: decoding using big LM with selected keywords (both positive and negative data)

### Other scripts

1.  `combine_dataset.sh`: combine datasets in Kaldi format using Kaldi utility script `./utils/combine_data.sh`;
2. `check_eval_process.sh`: used to check the progress during the decoding process;
3. `run_20190308.sh`: wrapper of decoding and performance check (script in the main repo) for the experiment of the 5 sets of selected keywords. 

## Decoding experiments

1. Experiment 1: 
   1. Experiment with decoding isolated words (data originally provided from Jaekwon, containing Masa's voice only), using small keyword LMs only;
   2. Corresponding data version: `data/cKWS_masa`
2. Experiment 2:
   1. Experiment with decoding isolated words (extracted from synthesized speech) using small keywords LM only;
   2. Corresponding data version: `exp01`
3. Experiment 3:
   1. Experiment with decoding isolated words (provided by Lakshmish) using small keyword LMs only;
   2. Corresponding data version: `exp01`
4. Experiment 4:
   1. Experiment with decoding utterance using small keyword LMs only;
   2. Corresponding data version: `exp02`
5. Experiment 5:
   1. Experiment with positive data only
   2. Corresponding data version: `exp02`
6. Experiment 6:
   1. Experiment with original data (both positive and negative)
   2. Corresponding data version: `exp03`
7. Experiment 7:
   1. Experiment with normalized data (both positive and negative), and with silence-inserted data (with appendix '_kw15')
   2. Corresponding data version: `exp04` (normalized) and `exp05` (silence-inserted, 0.25-1)

