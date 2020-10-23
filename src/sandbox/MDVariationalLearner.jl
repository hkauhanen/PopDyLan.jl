"""
A variational learner (Yang 2000) and its ``n``-grammar generalization (Kauhanen 2019).

# References

Kauhanen, H. (2019) Stable variation in multidimensional competition. In A. Breitbarth,
M. Bouzouita, L. Danckaert & M. Farasyn (eds.), *The determinants of diachronic
stability*, 263–290. Amsterdam: John Benjamins. <https://doi.org/10.1075/la.254.11kau>

Yang, C. D. (2000) Internal and external forces in language change. *Language Variation
and Change*, 12, 231–250. <https://doi.org/10.1017/S0954394500123014>
"""
mutable struct VariationalLearner <: AbstractVariationalLearner
  grammar::PolyvalentVariable
  gamma::Float64
  advantages::Array{Float64,2}
end


"""
    VariationalLearner(gamma::Float64, a1::Float64, a2::Float64, p0::Array{Float64})

Construct a classical 2-grammar (i.e. 1-parameter) variational learner with learning
rate `gamma`, grammatical advantages `a1` and `a2`, and initial state `p0`.
"""
function VariationalLearner(gamma::Float64, a1::Float64, a2::Float64, p0::Array{Float64})
  VariationalLearner(PolyvalentVariable(p0), gamma, [0 a2; a1 0])
end


"""
    VariationalLearner(gamma::Float64, a1::Float64, a2::Float64)

Construct a classical 2-grammar (i.e. 1-parameter) variational learner with learning
rate `gamma` and grammatical advantages `a1` and `a2`. The initial state is set
to ``(p_1, p_2) = (0.5, 0.5)``.
"""
function VariationalLearner(gamma::Float64, a1::Float64, a2::Float64)
  VariationalLearner(PolyvalentVariable([0.5, 0.5]), gamma, [0 a2; a1 0])
end


"""
    act!(x::AbstractVariationalLearner, y::VariationalLearner)

Make variational learner `x` act on variational learner `y`, i.e. let `y`
learn using the (multidimensional) linear reward–penalty learning algorithm
from an input sentence provided by `x`.

# References
Bush, R. R. & Mosteller, F. (1955) *Stochastic models for learning*. New York, NY: Wiley.

Narendra, K. & Thathachar, M. A. L. (1989) *Learning automata: an introduction.*
Englewood Cliffs, NJ: Prentice-Hall.
"""
function act!(x::AbstractVariationalLearner, y::VariationalLearner)
  spoken_grammar = speak(x)
  n = length(y.grammar.x)
  picked_grammar = Distributions.wsample(1:n, y.grammar.x)
  parsing_failure_prob = y.advantages[picked_grammar, spoken_grammar]
  if rand() < parsing_failure_prob
    y.grammar.x[picked_grammar] *= (1-y.gamma)
    y.grammar.x[1:end .!= picked_grammar] .= y.gamma/(n - 1) .+ (1 - y.gamma)*y.grammar.x[1:end .!= picked_grammar]
  else
    y.grammar.x[picked_grammar] += y.gamma*(1 - y.grammar.x[picked_grammar])
    y.grammar.x[1:end .!= picked_grammar] .= (1 - y.gamma)*y.grammar.x[1:end .!= picked_grammar]
  end
end


"""
    speak(x::VariationalLearner)

Make variational learner `x` "speak", i.e. draw one of the grammars
according to the speaker's probability distribution.
"""
function speak(x::VariationalLearner)
  Distributions.wsample(1:length(x.grammar.x), x.grammar.x)
end
