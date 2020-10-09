"""
    chebyshev(x::Point{Int}, y::Point{Int})

Find the Chebyshev distance between two integer points.
"""
function chebyshev(x::Point{Int}, y::Point{Int})
  max(abs(x.x - y.x), abs(y.x - y.y))
end


"""
Zipf–Chebyshev community: speakers are distributed on a regular 2D square lattice 
with fixed boundary conditions, the location of each speaker represented 
as an integer point. The probability of interaction of two randomly chosen 
speakers ``x`` and ``y`` is distributed as the power law

```math
P(x,y) = P(y,x) \\sim \\frac{1}{(d(x,y) + 1)^\\lambda}
```

where ``d(x,y)`` is their Chebyshev distance on the lattice and ``\\lambda`` is
a decay exponent.
"""
mutable struct ZipfChebyshevCommunity <: AbstractDiscretePlanarCommunity
  # Speaker census, as usual for all Communities
  census::Array{AbstractSpeaker}

  # Coordinates of each speaker
  coordinates::Array{Point{Int}}

  # Lookup table: assigns an array of speaker indices to pairs (s,d),
  # where s is a speaker index and d is a Chebyshev distance. This is
  # used to find the potential interlocutors of speaker s at distance d.
  lookup::Dict{Tuple{Int,Int}, Array{Int}}

  # Size of the community (lattice side length)
  size::Int

  # Decay exponent
  de::Float64

  # An array of probabilities. When a Zipf–Chebyshev community is constructed
  # using the default constructor, this is set so that the i-th element equals
  # 1/(1 + i)^lambda, where lambda is the decay exponent supplied at construction.
  probabilities::Array{Float64}

  # Integer that keeps track of how many actions have occurred.
  actions::Int
end


"""
    ZipfChebyshevCommunity(N::Int, lambda::Float64)

Construct a Zipf–Chebyshev community of size `N` by `N`, with decay exponent `lambda`.
"""
function ZipfChebyshevCommunity(N::Int, lambda::Float64)
  ZipfChebyshevCommunity(Array{AbstractSpeaker}(undef, 0), Array{Point{Int}}(undef, 0), Dict{Tuple{Int,Int}, Array{Int}}(), N, lambda, get_chebyshev_probabilities(N-1, lambda), 0)
end


"""
    inject!(x::AbstractSpeaker, y::ZipfChebyshevCommunity)

Insert a speaker into a Zipf–Chebyshev community.
"""
function inject!(x::AbstractSpeaker, y::ZipfChebyshevCommunity)
  no_speakers = length(y.census)
  push!(y.census, x)
  push!(y.coordinates, Point{Int}(rand(1:y.size), rand(1:y.size)))
  if no_speakers > 1
    for z in 1:(no_speakers - 1)
      dist = chebyshev(y.coordinates[end], y.coordinates[z])
      if !haskey(y.lookup, (no_speakers, dist))
        y.lookup[(no_speakers, dist)] = Array{Int}(undef, 0)
      end
      push!(y.lookup[(no_speakers, dist)], z)
      if !haskey(y.lookup, (z, dist))
        y.lookup[(z, dist)] = Array{Int}(undef, 0)
      end
      push!(y.lookup[z, dist], no_speakers)
    end
  end
end


"""
    eject!(x::Int, y::ZipfChebyshevCommunity)

Remove a speaker from a Zipf–Chebyshev community.

!!! note
    Ejecting a speaker from a Zipf–Chebyshev community forces a recalculation of an underlying dictionary that maps speaker–distance pairs to arrays of speakers, and is therefore not expected to be particularly performant, especially for large communities. The current implementation of `ZipfChebyshevCommunity` is optimized for communities of fixed speakers; other implementations will be more beneficial if the community is to be rewired across the simulation.
"""
function eject!(x::Int, y::ZipfChebyshevCommunity)
  # Delete dictionary entries involving speaker; update keys
  # of speakers that come after the removed speaker in the census;
  # and update values of the dictionary.
  for k in keys(y.lookup)
    if k[1] == x
      delete!(y.lookup, k)
    else
      tmp_value = y.lookup[k]
      tmp_value = setdiff(tmp_value, x)
      delete!(y.lookup, k)
      if length(tmp_value) > 0
        for i in 1:length(tmp_value)
          if tmp_value[i] > x
            tmp_value[i] = tmp_value[i] - 1
          end
        end
        if k[1] > x
          y.lookup[(k[1] - 1, k[2])] = tmp_value
        else
          y.lookup[k] = tmp_value
        end
      end
    end
  end

  # Splice the census and coordinates fields.
  splice!(y.census, x)
  splice!(y.coordinates, x)
end


"""
The probability decay function for Zipf-Chebyshev communities; called
when a community is constructed to initialize the `probabilities` field.
"""
function get_chebyshev_probabilities(x::Int, de::Float64)
  1 ./ (1 .+ (0:x)) .^ de
end


function get_chebyshev_probability(dist::Int, de::Float64)
  1/(1 + dist)^de
end


"""
    rendezvous!(x::ZipfChebyshevCommunity)

Conduct a pairwise rendezvous between random speakers in a Zipf–Chebyshev community.
"""
function rendezvous!(x::ZipfChebyshevCommunity)
  # Select one speaker at random
  int1 = rand(1:length(x.census))

  # Select interaction distance at random
  dist = Distributions.wsample(0:(x.size - 1), x.probabilities)

  # Check if speaker has any neighbours at this distance
  haskey(x.lookup, (int1, dist)) || return false

  # If so, choose one of them uniformly at random
  potentials = x.lookup[(int1, dist)]
  length(potentials) > 0 || return false
  int2 = rand(potentials)

  # Act both ways
  act!(x.census[int1], x.census[int2])
  act!(x.census[int2], x.census[int1])
  x.actions += 2
end


"""
    weighted_degree_centrality!(x::Int, y::ZipfChebyshevCommunity)

Calculate the weighted degree centrality of the `x`th speaker in a Zipf–Chebyshev
community.
"""
function weighted_degree_centrality(x::Int, y::ZipfChebyshevCommunity)
  wdc = 0
  for s in setdiff(1:length(y.census), x)
    dist = chebyshev(y.coordinates[x], y.coordinates[s])
    wdc += get_chebyshev_probability(dist, y.de)
  end
  wdc
end


function weighted_degree_centrality(x::ZipfChebyshevCommunity)
  out = Array{Float64}(undef, length(x.census))
  for i in 1:length(x.census)
    out[i] = weighted_degree_centrality(i, x)
  end
  out
end
