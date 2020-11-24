"""
A pool community is a well-mixing finite community, i.e. one in
which everyone is connected to everyone else.
"""
mutable struct PoolCommunity{T<:AbstractSpeaker} <: AbstractCommunity
  census::Array{AbstractSpeaker}
  actions::Int

  PoolCommunity{T}() where {T<:AbstractSpeaker} = new(Array{T}(undef, 0), 0)
end
