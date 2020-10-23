"""
A classical 2-grammar (1-parameter) variational learner (Yang 2000).

# Reference

Yang, C. D. (2000) Internal and external forces in language change. *Language Variation
and Change*, 12, 231–250. <https://doi.org/10.1017/S0954394500123014>
"""
mutable struct VariationalLearner <: AbstractOneDimVariationalLearner
  grammar::BinaryVariable
  gamma::Float64
  advantages::Array{Float64,2}
end


"""
    VariationalLearner(gamma::Float64, a1::Float64, a2::Float64, p0::Float64)

Construct a classical 2-grammar (i.e. 1-parameter) variational learner with learning
rate `gamma`, grammatical advantages `a1` and `a2`, and initial state `p0`.
"""
function VariationalLearner(gamma::Float64, a1::Float64, a2::Float64, p0::Float64)
  VariationalLearner(BinaryVariable(p0), gamma, [0 a2; a1 0])
end


"""
    VariationalLearner(gamma::Float64, a1::Float64, a2::Float64)

Construct a classical 2-grammar (i.e. 1-parameter) variational learner with learning
rate `gamma` and grammatical advantages `a1` and `a2`. The initial state is set
to ``(p_1, p_2) = (0.5, 0.5)``.
"""
function VariationalLearner(gamma::Float64, a1::Float64, a2::Float64)
  VariationalLearner(BinaryVariable(0.5), gamma, [0 a2; a1 0])
end


"""
    act!(x::VariationalLearner, y::VariationalLearner)

Make variational learner `x` act on variational learner `y`, i.e. let `y`
learn using the (two-action) linear reward–penalty learning algorithm
from an input sentence provided by `x`.

# References
Bush, R. R. & Mosteller, F. (1955) *Stochastic models for learning*. New York, NY: Wiley.

Narendra, K. & Thathachar, M. A. L. (1989) *Learning automata: an introduction.*
Englewood Cliffs, NJ: Prentice-Hall.
"""
function act!(x::VariationalLearner, y::VariationalLearner)
  # make x speak
  spoken_grammar = speak(x)

  # make y choose grammar
  picked_grammar = speak(y)

  # probability that chosen grammar does NOT parse input
  parsing_failure_prob = y.advantages[picked_grammar, spoken_grammar]

  # learn
  if picked_grammar == 1
    if rand() < parsing_failure_prob # if not parsed
      y.grammar.x *= (1-y.gamma)
    else # if parsed
      y.grammar.x += y.gamma*(1 - y.grammar.x[picked_grammar])
    end
  else
    if rand() < parsing_failure_prob # if not parsed
      y.grammar.x += y.gamma*(1 - y.grammar.x[picked_grammar])
    else # if parsed
      y.grammar.x *= (1-y.gamma)
    end
  end
end

