// nnet3/nnet-chain-training.cc

// Copyright      2015    Johns Hopkins University (author: Daniel Povey)

// See ../../COPYING for clarification regarding multiple authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
// THIS CODE IS PROVIDED *AS IS* BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION ANY IMPLIED
// WARRANTIES OR CONDITIONS OF TITLE, FITNESS FOR A PARTICULAR PURPOSE,
// MERCHANTABLITY OR NON-INFRINGEMENT.
// See the Apache 2 License for the specific language governing permissions and
// limitations under the License.

#include "nnet3/nnet-chain-training.h"
#include "nnet3/nnet-utils.h"

namespace kaldi {
namespace nnet3 {

NnetChainTrainer::NnetChainTrainer(const NnetTrainerOptions &nnet_config,
                                   const chain::ChainTrainingOptions &chain_config,
                                   const fst::StdVectorFst &den_fst,
                                   Nnet *nnet):
    nnet_config_(nnet_config),
    chain_config_(chain_config),
    den_graph_(den_fst, nnet->OutputDim("output")),
    nnet_(nnet),
    compiler_(*nnet, nnet_config_.optimize_config),
    num_minibatches_processed_(0) {
  if (nnet_config.zero_component_stats)
    ZeroComponentStats(nnet);
  if (nnet_config.momentum == 0.0 && nnet_config.max_param_change == 0.0) {
    delta_nnet_= NULL;
  } else {
    KALDI_ASSERT(nnet_config.momentum >= 0.0 &&
                 nnet_config.max_param_change >= 0.0);
    delta_nnet_ = nnet_->Copy();
    bool is_gradient = false;  // setting this to true would disable the
                               // natural-gradient updates.
    SetZero(is_gradient, delta_nnet_);
  }
}


void NnetChainTrainer::Train(const NnetChainExample &chain_eg) {
  bool need_model_derivative = true;
  ComputationRequest request;
  GetChainComputationRequest(*nnet_, chain_eg, need_model_derivative,
                             nnet_config_.store_component_stats,
                             &request);
  const NnetComputation *computation = compiler_.Compile(request);

  NnetComputer computer(nnet_config_.compute_config, *computation,
                        *nnet_,
                        (delta_nnet_ == NULL ? nnet_ : delta_nnet_));
  // give the inputs to the computer object.
  computer.AcceptInputs(*nnet_, chain_eg.inputs);
  computer.Forward();

  this->ProcessOutputs(chain_eg, &computer);
  computer.Backward();

  if (delta_nnet_ != NULL) {
    BaseFloat scale = (1.0 - nnet_config_.momentum);
    if (nnet_config_.max_param_change != 0.0) {
      BaseFloat param_delta =
          std::sqrt(DotProduct(*delta_nnet_, *delta_nnet_)) * scale;
      if (param_delta > nnet_config_.max_param_change) {
        if (param_delta - param_delta != 0.0) {
          KALDI_WARN << "Infinite parameter change, will not apply.";
          SetZero(false, delta_nnet_);
        } else {
          scale *= nnet_config_.max_param_change / param_delta;
          KALDI_LOG << "Parameter change too big: " << param_delta << " > "
                    << "<--max-param-change=" << nnet_config_.max_param_change
                    << ", scaling by "
                    << nnet_config_.max_param_change / param_delta;
        }
      }
    }
    AddNnet(*delta_nnet_, scale, nnet_);
    ScaleNnet(nnet_config_.momentum, delta_nnet_);
  }
}


void NnetChainTrainer::ProcessOutputs(const NnetChainExample &eg,
                                      NnetComputer *computer) {
  // normally the eg will have just one output named 'output', but
  // we don't assume this.
  std::vector<NnetChainSupervision>::const_iterator iter = eg.outputs.begin(),
      end = eg.outputs.end();
  for (; iter != end; ++iter) {
    const NnetChainSupervision &sup = *iter;
    int32 node_index = nnet_->GetNodeIndex(sup.name);
    if (node_index < 0 ||
        !nnet_->IsOutputNode(node_index))
      KALDI_ERR << "Network has no output named " << sup.name;

    const CuMatrixBase<BaseFloat> &nnet_output = computer->GetOutput(sup.name);
    CuMatrix<BaseFloat> nnet_output_deriv(nnet_output.NumRows(),
                                          nnet_output.NumCols(),
                                          kUndefined);

    BaseFloat tot_objf, tot_weight;

    ComputeChainObjfAndDeriv(chain_config_, den_graph_,
                             sup.supervision, nnet_output,
                             &tot_objf, &tot_weight,
                             &nnet_output_deriv);

    computer->AcceptOutputDeriv(sup.name, &nnet_output_deriv);

    objf_info_[sup.name].UpdateStats(sup.name, nnet_config_.print_interval,
                                     num_minibatches_processed_++,
                                     tot_weight, tot_objf);
  }
}


bool NnetChainTrainer::PrintTotalStats() const {
  unordered_map<std::string, ObjectiveFunctionInfo>::const_iterator
      iter = objf_info_.begin(),
      end = objf_info_.end();
  bool ans = false;
  for (; iter != end; ++iter) {
    const std::string &name = iter->first;
    const ObjectiveFunctionInfo &info = iter->second;
    ans = ans || info.PrintTotalStats(name);
  }
  return ans;
}


NnetChainTrainer::~NnetChainTrainer() {
  delete delta_nnet_;
}


} // namespace nnet3
} // namespace kaldi