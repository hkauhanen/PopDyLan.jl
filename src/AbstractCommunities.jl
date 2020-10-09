"""
Abstract community. The top node of the Community type hierarchy.
"""
abstract type AbstractCommunity end

"""
Abstract network community. Speakers are nodes of some network.
"""
abstract type AbstractNetworkCommunity <: AbstractCommunity end

"""
Abstract spatial network community: network with some sort of spatial
information attached to each node.
"""
abstract type AbstractSpatialNetworkCommunity <: AbstractNetworkCommunity end

"""
Abstract spatial community. Represents any type of community in which
speakers have a spatial representation (e.g. a point on a plane).
"""
abstract type AbstractSpatialCommunity <: AbstractCommunity end

"""
Abstract planar community: speakers on some kind of 2D structure.
"""
abstract type AbstractPlanarCommunity <: AbstractSpatialCommunity end

"""
Abstract discrete planar community: a planar community in which
speaker locations are expressed as integers (rather than e.g. floats).
"""
abstract type AbstractDiscretePlanarCommunity <: AbstractPlanarCommunity end

"""
Abstract Zipfian lattice community. Interaction probability decays
over distance.
"""
abstract type AbstractZipfLatticeCommunity <: AbstractDiscretePlanarCommunity end
