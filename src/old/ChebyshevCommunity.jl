"""
Representation of an integer point.
"""
mutable struct IntPoint
  x::Int
  y::Int
end

"""
Find the Chebyshev distance between two IntPoints.
"""
function chebyshev(x::IntPoint, y::IntPoint)
  max(abs(x.x - y.x), abs(y.x - y.y))
end

"""
Chebyshev community: speakers are distributed on a regular 2D lattice with
fixed boundary conditions, the
location of each speaker represented as an integer point. The probability of
interaction of two randomly chosen speakers ``x`` and ``y`` is distributed as
the power law

```math
P(x,y) = P(y,x) \\sim \\frac{1}{(d(x,y) + 1)^\\lambda}
```

where ``d(x,y)`` is their Chebyshev distance on the lattice and ``\\lambda`` is
a decay exponent.
"""
mutable struct ChebyshevCommunity <: AbstractDiscretePlanarCommunity
  census::Array{AbstractSpeaker}
  coordinates::Array{IntPoint}
  xlim::Array{Int}
  ylim::Array{Int}
  decay_exponent::Float64
  interactions::Int
end

"""
    ChebyshevCommunity(N::Int, de::Float64)

Construct a Chebyshev community of size `N` by `N`, with decay exponent `de`.
"""
function ChebyshevCommunity(N::Int, de::Float64)
  ChebyshevCommunity(Array{AbstractSpeaker}(undef, 0), Array{IntPoint}(undef, 0), [1, N], [1, N], de, 0)
end

"""
    rendezvous!(x::ChebyshevCommunity, y::Int, z::Int)

Conduct a pairwise rendezvous between speakers with indices y and z in
a Chebyshev community.
"""
function rendezvous!(x::ChebyshevCommunity, y::Int, z::Int)
  rand() < 1/(1 + chebyshev(x.coordinates[y], x.coordinates[z]))^x.decay_exponent || return false
  act!(x.census[y], x.census[z])
  act!(x.census[z], x.census[y])
  x.interactions += 2
end


