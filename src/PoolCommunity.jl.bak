"""
A pool community is a well-mixing finite community, i.e. one in
which everyone is connected to everyone else.
"""
mutable struct PoolCommunity <: AbstractCommunity
  census::Array{AbstractSpeaker}
  actions::Int

  PoolCommunity() = new(Array{AbstractSpeaker}(undef, 0), 0)
end
