module PopDyLan

# Dependencies
import Distributions
import LightGraphs
import Random
import SimpleWeightedGraphs

# Abstract type definitions
include("AbstractCommunities.jl")
include("AbstractGrammars.jl")
include("AbstractSpeakers.jl")

# Common types and functions
include("common.jl")

# Community source code
include("Communities.jl")
include("MultiplexCommunity.jl")
include("PoolCommunity.jl")
include("ZipfManhattanCommunity.jl")
include("ZipfTravellerCommunity.jl")

# Grammar source code
include("BinaryVariable.jl")
include("PolyvalentVariable.jl")

# Speaker source code
include("EmptySpeaker.jl")
include("MomentumSelector.jl")
include("NeutralVariationalLearner.jl")
include("Speakers.jl")
include("VariationalLearner.jl")

# Auxiliary source code
include("auxiliaries.jl")

# Exports (common stuff)
export chebyshev
export manhattan
export Point
export zipf

# Exports (communities)
export MultiplexCommunity
export PoolCommunity
export ZipfManhattanCommunity
export ZipfTravellerCommunity
export eject!
export inject!
export rendezvous!
export travel!
export travel_all!
export weighted_degree_centrality

# Exports (speakers)
export EmptySpeaker
export MomentumSelector
export NeutralVariationalLearner
export VariationalLearner
export act!
export speak

# Exports (grammars)
export BinaryVariable
export PolyvalentVariable

# Exports (auxiliaries)
export characterize
export characterize_bylocation
export characterize_momentum
export characterize_momentum_bylocation

end # module
