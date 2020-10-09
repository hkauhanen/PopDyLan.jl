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

```math
P(x,y) = P(y,x) = \\frac{1}{1 + d(x,y)^\\lambda}
```

where ``d(x,y)`` is their Chebyshev distance on the lattice and ``\\lambda`` is
a decay exponent.
"""
mutable struct ChebyshevCommunity <: AbstractDiscretePlanarCommunity
  census::Array{AbstractSpeaker}
  coordinates::Array{IntPoint}
  graphs::Array{SimpleWeightedGraphs.SimpleWeightedGraph}
  xlim::Array{Int}
  ylim::Array{Int}
  decay_exponent::Float64
  distance_cap::Int
  interactions::Int
end

"""
ChebyshevCommunity(N::Int, de::Float64)

Construct a Chebyshev community of size `N` by `N`, with decay exponent `de`.
"""
function ChebyshevCommunity(N::Int, de::Float64, cap::Int)
  ChebyshevCommunity(Array{AbstractSpeaker}(undef, 0), Array{IntPoint}(undef, 0), [SimpleWeightedGraphs.SimpleWeightedGraph()], [1, N], [1, N], de, cap, 0)
end

"""
inject!(x::AbstractSpeaker, y::ChebyshevCommunity)

Inject a speaker into a `ChebyshevCommunity`. The speaker is connected to all
existing speakers and the edge between the speakers assigned the weight

```@math
\\frac{1}{1 + d^\\lambda}
```

where ``d`` is the Chebyshev distance between the two speakers and ``\\lambda``
is the decay exponent associated with the community.
"""
function inject!(x::AbstractSpeaker, y::ChebyshevCommunity)
  push!(y.census, x)
  SimpleWeightedGraphs.add_vertex!(y.graphs[1])
  push!(y.coordinates, IntPoint(rand(y.xlim[1]:y.xlim[2]), rand(y.ylim[1]:y.ylim[2])))

  if length(y.census) != 1
    for i in 1:(length(y.census) - 1)
      dist = chebyshev(y.coordinates[length(y.census)], y.coordinates[i])
      if (dist <= y.distance_cap)
        weight = 1/(1 + dist^y.decay_exponent)
        SimpleWeightedGraphs.add_edge!(y.graphs[1], length(y.census), i, weight)
      end
    end
  end
end


function rendezvous!(x::ChebyshevCommunity)
  no_speakers = length(x.census)
  int1 = rand(1:no_speakers)
  int2 = Distributions.wsample(1:no_speakers, x.graphs[1].weights[int1,:])
  act!(x.census[int1], x.census[int2])
  act!(x.census[int2], x.census[int1])
  x.interactions += 2
end


"""
rendezvous!(x::ChebyshevCommunity, y::Int, z::Int)

Conduct a pairwise rendezvous between speakers with indices y and z in
a Chebyshev community.
"""
function rendezvous!(x::ChebyshevCommunity, y::Int, z::Int)
  rand() < 1/(1 + chebyshev(x.coordinates[y], x.coordinates[z])^x.decay_exponent) || return false
  act!(x.census[y], x.census[z])
  act!(x.census[z], x.census[y])
  x.interactions += 2
end


