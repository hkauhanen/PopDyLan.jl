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
mutable struct NeutralVariationalLearner <: AbstractVariationalLearner
  grammar::PolyvalentVariable
  gamma::Float64
end


"""
    NeutralVariationalLearner(gamma::Float64, p0::Array{Float64})

Construct a 2-grammar neutral variational learner with learning
rate `gamma` and initial state `p0`.
"""
function NeutralVariationalLearner(gamma::Float64, p0::Array{Float64})
  NeutralVariationalLearner(PolyvalentVariable(p0), gamma)
end


"""
    NeutralVariationalLearner(gamma::Float64)

Construct a 2-grammar neutral variational learner with learning
rate `gamma` and initial state ``(p_1, p_2) = (0.5, 0.5)``.
"""
function NeutralVariationalLearner(gamma::Float64)
  NeutralVariationalLearner(PolyvalentVariable([0.5, 0.5]), gamma)
end


"""
    act!(x::AbstractVariationalLearner, y::NeutralVariationalLearner)

Make variational learner `x` act on neutral variational learner `y`, i.e. let `y`
learn using the (multidimensional) linear reward–penalty learning algorithm
from an input sentence provided by `x`.

# References
Bush, R. R. & Mosteller, F. (1955) *Stochastic models for learning*. New York, NY: Wiley.

Narendra, K. & Thathachar, M. A. L. (1989) *Learning automata: an introduction.*
Englewood Cliffs, NJ: Prentice-Hall.
"""
function act!(x::AbstractVariationalLearner, y::NeutralVariationalLearner)
  spoken_grammar = speak(x)
  n = length(y.grammar.x)
  picked_grammar = Distributions.wsample(1:n, y.grammar.x)
  y.grammar.x[picked_grammar] += y.gamma*(1 - y.grammar.x[picked_grammar])
  y.grammar.x[1:end .!= picked_grammar] .= (1 - y.gamma)*y.grammar.x[1:end .!= picked_grammar]
end


"""
    speak(x::NeutralVariationalLearner)

Make neutral variational learner `x` "speak", i.e. draw one of the grammars
according to the speaker's probability distribution.
"""
function speak(x::NeutralVariationalLearner)
  Distributions.wsample(1:length(x.grammar.x), x.grammar.x)
end
