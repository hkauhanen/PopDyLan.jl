"""
A performant version of `VariationalLearner` with zero advantages for each 
grammar ("neutral learning").
"""
mutable struct NeutralVariationalLearner <: AbstractOneDimVariationalLearner
  grammar::BinaryVariable
  gamma::Float64
  advantages::Array{Float64,2}
end


"""
    NeutralVariationalLearner(gamma::Float64, p0::Float64)

Construct a neutral 2-grammar (i.e. 1-parameter) variational learner with learning
rate `gamma` and initial state `p0`.
"""
function NeutralVariationalLearner(gamma::Float64, p0::Float64)
  NeutralVariationalLearner(BinaryVariable(p0), gamma, [0 0; 0 0])
end


"""
    NeutralVariationalLearner(gamma::Float64)

Construct a neutral 2-grammar (i.e. 1-parameter) variational learner with learning
rate `gamma` and initial state ``(p_1, p_2) = (0.5, 0.5)``.
"""
function NeutralVariationalLearner(gamma::Float64)
  NeutralVariationalLearner(BinaryVariable(0.5), gamma, [0 0; 0 0])
end


"""
    act!(x::AbstractOneDimVariationalLearner, y::NeutralVariationalLearner)

Make variational learner `x` act on variational learner `y`, i.e. let `y`
learn using the (two-action) linear reward–penalty learning algorithm
from an input sentence provided by `x`.

# References
Bush, R. R. & Mosteller, F. (1955) *Stochastic models for learning*. New York, NY: Wiley.

Narendra, K. & Thathachar, M. A. L. (1989) *Learning automata: an introduction.*
Englewood Cliffs, NJ: Prentice-Hall.
"""
function act!(x::AbstractOneDimVariationalLearner, y::NeutralVariationalLearner)
  # make x speak
  spoken_grammar = speak(x)

  # make y choose grammar
  n = length(y.grammar.x)
  picked_grammar = speak(y)

  # probability that chosen grammar does NOT parse input
  parsing_failure_prob = y.advantages[picked_grammar, spoken_grammar]

  # learn
  if picked_grammar == 1
    y.grammar.x += y.gamma*(1 - y.grammar.x[picked_grammar])
  else
    y.grammar.x *= (1-y.gamma)
  end
end


