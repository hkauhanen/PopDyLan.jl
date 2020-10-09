"""
Binary probabilistic variable; the probability of use of one value of a
binary variable.
"""
mutable struct BinaryVariable <: AbstractProbabilisticGrammar
  x::Float64
end
