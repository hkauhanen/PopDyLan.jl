"""
Momentum-based utterance selector, after Stadler et al. (2016).

# Reference

Stadler, K., Blythe, R. A., Smith, K. & Kirby, S. (2016) Momentum in language
change: a model of self-actuating s-shaped curves. *Language Dynamics and Change*,
6, 171–198. <https://doi.org/10.1163/22105832-00602005>
"""
mutable struct MomentumSelector <: AbstractUtteranceSelector
  grammar::BinaryVariable
  gamma_grammar::BinaryVariable
  alpha::Float64
  gamma::Float64
  b::Float64
  T::Int
  mmax::Float64
end


"""
    MomentumSelector(alpha::Float64, gamma::Float64, b::Float64, T::Int, x0::Float64)

Construct a `MomentumSelector` with learning rate `alpha`, short-term memory
smoothing factor `gamma`, momentum bias `b`, number of utterances per interaction `T`,
and initial frequency `x0`.
"""
function MomentumSelector(alpha::Float64, gamma::Float64, b::Float64, T::Int, x0::Float64)
  tmmax = log(alpha/gamma)/(alpha - gamma)
  mmax = exp(-gamma*tmmax) - exp(-alpha*tmmax)
  MomentumSelector(BinaryVariable(x0), BinaryVariable(x0), alpha, gamma, b, T, mmax)
end


"""
    act!(x::MomentumSelector, y::MomentumSelector)

Let one `MomentumSelector` act upon another, i.e. `x` speaks and `y` listens.
"""
function act!(x::MomentumSelector, y::MomentumSelector)
  println("yay")
  normalized_momentum = (y.gamma_grammar.x - y.grammar.x)/y.mmax
  observed_frequency = rand(Distributions.Binomial(x.T, x.grammar.x))/x.T

  transformed_frequency = 0.0
  
  if observed_frequency == 1.0
    transformed_frequency = 1.0
  elseif observed_frequency != 0.0
    transformed_frequency = observed_frequency + y.b*normalized_momentum
  end

  if transformed_frequency > 1.0
    transformed_frequency = 1.0
  elseif transformed_frequency < 0.0
    transformed_frequency = 0.0
  end

  y.grammar.x = y.alpha*transformed_frequency + (1-y.alpha)*y.grammar.x
  y.gamma_grammar.x = y.gamma*transformed_frequency + (1-y.gamma)*y.gamma_grammar.x
end


