"""
    inject!(x::AbstractSpeaker, y::AbstractCommunity)

Insert a speaker into a community.
"""
function inject!(x::AbstractSpeaker, y::AbstractCommunity)
  push!(y.census, x)
end

"""
    eject!(x::Int, y::AbstractCommunity)

Remove a speaker with index `x` from a community.
"""
function eject!(x::Int, y::AbstractCommunity)
  splice!(y.census, x)
end

"""
    rendezvous!(x::AbstractCommunity, y::Int, z::Int)

Conduct a rendezvous between speakers indexed by `y` and `z` in community `x`.
"""
function rendezvous!(x::AbstractCommunity, y::Int, z::Int)
  act!(x.census[y], x.census[z])
  act!(x.census[z], x.census[y])
  x.actions += 2
end

"""
    rendezvous!(x::AbstractCommunity)

Conduct a rendezvous between two speakers chosen at random in community `x`.
"""
function rendezvous!(x::AbstractCommunity)
  length(x.census) > 1 || return false
  int1 = 0
  int2 = 0
  while true
    int1 = rand(1:length(x.census))
    int2 = rand(1:length(x.census))
    int1 != int2 && break
  end
  rendezvous!(x, int1, int2)
end




"""
    inject!(x::AbstractSpeaker, y::AbstractZipfLatticeCommunity)

Insert a speaker into a Zipfian lattice community.
"""
function inject!(x::AbstractSpeaker, y::AbstractZipfLatticeCommunity)
  no_speakers = length(y.census)
  push!(y.census, x)
  push!(y.coordinates, Point{Int}(rand(1:y.size), rand(1:y.size)))
  if no_speakers > 1
    for z in 1:(no_speakers - 1)
      dist = y.distance(y.coordinates[end], y.coordinates[z])
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
    eject!(x::Int, y::AbstractZipfLatticeCommunity)

Remove a speaker from a Zipfian lattice community.

!!! note
    Ejecting a speaker from a Zipfian lattice community forces a recalculation of an underlying dictionary that maps speaker–distance pairs to arrays of speakers, and is therefore not expected to be particularly performant, especially for large communities. The current implementation of `AbstractZipfLatticeCommunity` is optimized for communities of fixed speakers; other implementations will be more beneficial if the community is to be rewired across the simulation.
    """
    function eject!(x::Int, y::AbstractZipfLatticeCommunity)
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
    rendezvous!(x::AbstractZipfLatticeCommunity)

Conduct a pairwise rendezvous between random speakers in a Zipfian lattice community.
"""
function rendezvous!(x::AbstractZipfLatticeCommunity)
  # Select one speaker at random
  int1 = rand(1:length(x.census))

  # Select interaction distance at random
  dist = Distributions.wsample(x.possible_distances, x.probabilities)

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
    rendezvous!(x::AbstractZipfLatticeCommunity, T::Int)

Select two speakers at random and conduct ``T`` rendezvous with them
in a Zipfian lattice community.
"""
function rendezvous!(x::AbstractZipfLatticeCommunity, T::Int)
  # Select one speaker at random
  int1 = rand(1:length(x.census))

  # Select interaction distance at random
  dist = Distributions.wsample(x.possible_distances, x.probabilities)

  # Check if speaker has any neighbours at this distance
  haskey(x.lookup, (int1, dist)) || return false

  # If so, choose one of them uniformly at random
  potentials = x.lookup[(int1, dist)]
  length(potentials) > 0 || return false
  int2 = rand(potentials)

  # Act both ways
  for i in 1:T
    act!(x.census[int1], x.census[int2])
    act!(x.census[int2], x.census[int1])
    x.actions += 2
  end
end



"""
    weighted_degree_centrality!(x::Int, y::AbstractZipfLatticeCommunity)

Calculate the weighted degree centrality of the `x`th speaker in a Zipfian lattice
community.
"""
function weighted_degree_centrality(x::Int, y::AbstractZipfLatticeCommunity)
  wdc = 0
  for s in setdiff(1:length(y.census), x)
    dist = y.distance(y.coordinates[x], y.coordinates[s])
    wdc += y.probabilities[dist + 1]
  end
  wdc
end


"""
    weighted_degree_centrality(x::AbstractZipfLatticeCommunity)

Return all weighted degree centralities in a Zipfian lattice community.
"""
function weighted_degree_centrality(x::AbstractZipfLatticeCommunity)
  out = Array{Float64}(undef, length(x.census))
  for i in 1:length(x.census)
    out[i] = weighted_degree_centrality(i, x)
  end
  out
end
