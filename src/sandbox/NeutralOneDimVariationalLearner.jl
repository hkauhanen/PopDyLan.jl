"""
A neutral variational learner (Yang 2000) and its ``n``-grammar generalization (Kauhanen 2019).
This is a performant variant of the `VariationalLearner` type in the case that
the grammatical advantage probabilities are all zero.

# References

Kauhanen, H. (2019) Stable variation in multidimensional competition. In A. Breitbarth,
M. Bouzouita, L. Danckaert & M. Farasyn (eds.), *The determinants of diachronic
stability*, 263–290. Amsterdam: John Benjamins. <https://doi.org/10.1075/la.254.11kau>

Yang, C. D. (2000) Internal and external forces in language change. *Language Variation
and Change*, 12, 231–250. <https://doi.org/10.1017/S0954394500123014>
"""
mutable struct NeutralOneDimVariationalLearner <: AbstractVariationalLearner
  grammar::Float64
  gamma::Float64
end


"""
    NeutralOneDimVariationalLearner(gamma::Float64, p0::Array{Float64})

Construct a 2-grammar neutral variational learner with learning
rate `gamma` and initial state `p0`.
"""
function NeutralOneDimVariationalLearner(gamma::Float64, p0)
  NeutralOneDimVariationalLearner(p0, gamma)
end


"""
    NeutralOneDimVariationalLearner(gamma::Float64)

Construct a 2-grammar neutral variational learner with learning
rate `gamma` and initial state ``(p_1, p_2) = (0.5, 0.5)``.
"""
function NeutralOneDimVariationalLearner(gamma::Float64)
  NeutralOneDimVariationalLearner(0.5, gamma)
end


"""
    act!(x::AbstractVariationalLearner, y::NeutralOneDimVariationalLearner)

Make variational learner `x` act on neutral variational learner `y`, i.e. let `y`
learn using the (multidimensional) linear reward–penalty learning algorithm
from an input sentence provided by `x`.

# References
Bush, R. R. & Mosteller, F. (1955) *Stochastic models for learning*. New York, NY: Wiley.

Narendra, K. & Thathachar, M. A. L. (1989) *Learning automata: an introduction.*
Englewood Cliffs, NJ: Prentice-Hall.
"""
function act!(x::AbstractVariationalLearner, y::NeutralOneDimVariationalLearner)
  spoken_grammar = speak(x)
  picked_grammar = Distributions.wsample(1:2, [y.grammar, 1-y.grammar])
  if picked_grammar == 1
    y.grammar += y.gamma*(1 - y.grammar)
  else
    y.grammar -= y.gamma*y.grammar
  end
end


"""
    speak(x::NeutralOneDimVariationalLearner)

Make neutral variational learner `x` "speak", i.e. draw one of the grammars
according to the speaker's probability distribution.
"""
function speak(x::NeutralOneDimVariationalLearner)
  Distributions.wsample(1:2, [x.grammar, 1-x.grammar])
end
