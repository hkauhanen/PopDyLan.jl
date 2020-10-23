"""
    speak(x::AbstractOneDimVariationalLearner)

Make variational learner `x` "speak", i.e. draw one of the grammars
according to the speaker's probability distribution.
"""
function speak(x::AbstractOneDimVariationalLearner)
  Distributions.wsample(1:2, [x.grammar.x, 1 - x.grammar.x])
end
