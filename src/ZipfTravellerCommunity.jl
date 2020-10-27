"""
A 'Zipfian traveller community': speakers are located on a two-dimensional
lattice. Each speaker has a 'home' cell on the lattice, but also has the
option of travelling to another cell. The probability to travel to a cell
with coordinates ``x'`` and ``y'`` scales as the inverse of the distance
between that cell and the speaker's home (coordinates ``x`` and ``y``),
measured as the Manhattan distance ``d``:

```math
P \\propto \\frac{1}{(1 + d)^\\lambda}
```

where ``\\lambda`` is a scaling parameter.
"""
mutable struct ZipfTravellerCommunity <: AbstractDiscretePlanarCommunity
  # Census
  census::Array{AbstractSpeaker}

  # Spatial census
  spatial_census::Dict{Point{Int}, Array{Int}}

  # Speakers' homes
  coordinates::Array{Point{Int}}

  # Speakers' temporary (within-epoch) locations
  locations::Array{Point{Int}}

  # Lattice size
  size::Int

  # Decay exponent
  de::Float64

  # Probabilities
  probabilities::Array{Float64}

  # Distance function
  distance::Function

  # Range of possible distances
  possible_distances::Dict{Point{Int}, Array{Int}}

  # How many actions have occurred
  actions::Int

  # Cells at a given distance from given cell
  lookup::Dict{Tuple{Point{Int}, Int}, Array{Point{Int}}}
end


"""
    ZipfTravellerCommunity(K::Int, lambda::Float64)

Construct a Zipf traveller community of size `K` by `K` with scaling
parameter `lambda`.
"""
function ZipfTravellerCommunity(K::Int, lambda::Float64)
  # Possible distances on lattice
  possdist = collect(0:2*(K-1))

  # Possible distances for each cell
  possdistcell = Dict{Point{Int}, Array{Int}}()

  # Spatial census
  spatcens = Dict{Point{Int}, Array{Int}}()

  # Make lookup table
  lup = Dict{Tuple{Point{Int}, Int}, Array{Point{Int}}}()
  for x in 1:K
    for y in 1:K
      point = Point{Int}(x, y)
      for dist in possdist
        for i in 1:K
          for j in 1:K
            point2 = Point{Int}(i, j)
            if manhattan(point, point2) == dist
              if !haskey(possdistcell, point)
                possdistcell[point] = Array{Int}(undef, 0)
              end
              push!(possdistcell[point], dist)
              if !haskey(lup, (point, dist))
                lup[(point, dist)] = Array{Point{Int}}(undef, 0)
              end
              push!(lup[(point, dist)], point2)
            end
          end
        end
      end
      possdistcell[point] = unique(possdistcell[point])
      spatcens[point] = []
    end
  end

  # Construct
  ZipfTravellerCommunity(Array{AbstractSpeaker}(undef, 0), spatcens, Array{Point{Int}}(undef, 0), Array{Point{Int}}(undef, 0), K, lambda, zipf(2*(K-1) + 1, lambda), manhattan, possdistcell, 0, lup)
end


"""
    inject!(x::AbstractSpeaker, y::ZipfTravellerCommunity)

Insert a speaker into a Zipf traveller community.
"""
function inject!(x::AbstractSpeaker, y::ZipfTravellerCommunity)
  push!(y.census, x)
  home = Point{Int}(rand(1:y.size), rand(1:y.size))
  push!(y.coordinates, home)
  push!(y.locations, home)
  push!(y.spatial_census[home], length(y.census))
end


"""
    eject!(x::Int, y::ZipfTravellerCommunity)

Remove a speaker from a Zipf traveller community.
"""
function eject!(x::Int, y::ZipfTravellerCommunity)
  home = y.coordinates[x]
  loca = y.locations[x]
  splice!(y.census, x)
  splice!(y.coordinates, x)
  splice!(y.locations, x)
  y.spatial_census[loca] = setdiff(y.spatial_census[loca], x)
  for k in keys(y.spatial_census)
    for i in 1:length(y.spatial_census[k])
      if y.spatial_census[k][i] > x
        y.spatial_census[k][i] -= 1
      end
    end
  end
end


"""
    travel!(x::Int, y::ZipfTravellerCommunity)

Make speaker with index `x` travel in a Zipf traveller community.
"""
function travel!(x::Int, y::ZipfTravellerCommunity)
  home = y.coordinates[x]
  loca = y.locations[x]
  possdist = y.possible_distances[home]
  dist = Distributions.wsample(possdist, zipf(maximum(possdist) + 1, y.de))
  y.locations[x] = rand(y.lookup[(home, dist)])

  if y.locations[x] != loca
    y.spatial_census[loca] = setdiff(y.spatial_census[loca], x)
    push!(y.spatial_census[y.locations[x]], x)
  end
end


"""
    travel_all!(x::ZipfTravellerCommunity)

Make every speaker in a Zipf traveller community travel.
"""
function travel_all!(x::ZipfTravellerCommunity)
  for s in 1:length(x.census)
    travel!(s, x)
  end
end


"""
    travel!(x::ZipfTravellerCommunity)

Make a random speaker in a Zipf traveller community travel.
"""
function travel!(x::ZipfTravellerCommunity)
  travel!(rand(1:length(x.census)), x)
end


"""
    rendezvous!(x::ZipfTravellerCommunity)

Rendezvous in a Zipf traveller community (between two random speakers
currently in the same cell.
"""
function rendezvous!(x::ZipfTravellerCommunity)
  length(x.census) > 1 || return false
  int1 = rand(1:length(x.census))
  location = x.locations[int1]
  length(x.spatial_census[location]) > 1 || return false
  friends = setdiff(x.spatial_census[location], int1)
  int2 = rand(friends)
  rendezvous!(x, int1, int2)
end
