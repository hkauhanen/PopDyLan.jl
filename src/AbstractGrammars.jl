"""
Abstract grammar: top node of the Grammar type hierarchy.
"""
abstract type AbstractGrammar end

"""
Abstract probabilistic grammar: the speaker's knowledge of
language is a probability distribution.
"""
abstract type AbstractProbabilisticGrammar <: AbstractGrammar end

