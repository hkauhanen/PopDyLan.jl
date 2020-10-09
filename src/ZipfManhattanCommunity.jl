"""
Zipf–Manhattan community: speakers are distributed on a regular 2D square lattice 
with fixed boundary conditions, the location of each speaker represented 
as an integer point. The probability of interaction of two randomly chosen 
speakers ``x`` and ``y`` is distributed as Zipf's Law

```math
P(x,y) = P(y,x) \\propto \\frac{1}{(1 + d(x,y))^\\lambda}
```

where ``d(x,y)`` is their Manhattan distance on the lattice and ``\\lambda`` 
is a decay exponent.
"""
mutable struct ZipfManhattanCommunity <: AbstractZipfLatticeCommunity
  # Speaker census, as usual for all Communities
  census::Array{AbstractSpeaker}

  # Coordinates of each speaker
  coordinates::Array{Point{Int}}

  # Lookup table: assigns an array of speaker indices to pairs (s,d),
  # where s is a speaker index and d is a distance. This is
  # used to find the potential interlocutors of speaker s at distance d.
  lookup::Dict{Tuple{Int,Int}, Array{Int}}

  # Size of the community (lattice side length)
  size::Int

  # Decay exponent
  de::Float64

  # An array of probabilities. When a Zipf lattice community is constructed
  # using the default constructor, this is set so that the i-th element equals
  # 1/(1 + i)^lambda, where lambda is the decay exponent supplied at construction.
  probabilities::Array{Float64}

  # Distance function
  distance::Function

  # Range of possible distances on a lattice of this size, given above
  # distance metric.
  possible_distances::Array{Int}

  # Integer that keeps track of how many actions have occurred.
  actions::Int
end


"""
    ZipfManhattanCommunity(K::Int, lambda::Float64)

Construct a Zipf–Manhattan community of size `K` by `K`, with decay exponent `lambda`.
"""
function ZipfManhattanCommunity(K::Int, lambda::Float64)
  ZipfManhattanCommunity(Array{AbstractSpeaker}(undef, 0), Array{Point{Int}}(undef, 0), Dict{Tuple{Int,Int}, Array{Int}}(), K, lambda, zipf(2*(K-1) + 1, lambda), manhattan, collect(0:2*(K-1)), 0)
end

