"""
Multiplex network community.
"""
mutable struct MultiplexCommunity <: AbstractNetworkCommunity
  census::Array{AbstractSpeaker}
  graphs::Array{SimpleWeightedGraphs.SimpleWeightedDiGraph}

  MultiplexCommunity() = new(Array{AbstractSpeaker}(undef, 0), [SimpleWeightedGraphs.SimpleWeightedDiGraph()])
end
