"""
A polyvalent probabilistic variable; a probability distribution
over a number of variants.
"""
mutable struct PolyvalentVariable <: AbstractProbabilisticGrammar
  x::Array{Float64}
end
