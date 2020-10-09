"""
Abstract speaker: top node of the Speaker hierarchy.
"""
abstract type AbstractSpeaker end

"""
Abstract probabilistic Speaker: a speaker whose grammar is some
descendant of AbstractProbabilisticGrammar.
"""
abstract type AbstractProbabilisticSpeaker <: AbstractSpeaker end

"""
Abstract utterance selector: subsumes all types of instantiations
of the Utterance Selection Model.
"""
abstract type AbstractUtteranceSelector <: AbstractProbabilisticSpeaker end


