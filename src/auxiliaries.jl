"""
    characterize(x::AbstractCommunity)

Characterize the state of a community. Tries to form either a single number
or a vector that reflects the community's average behaviour, depending on
the types of grammars carried by speakers in the community.
"""
function characterize(x::AbstractCommunity)
  result = characterize(x.census[1])
  for person in x.census[2:end]
    result += characterize(person)
  end
  result/length(x.census)
end


"""
    characterize_bylocation(x::AbstractDiscretePlanarCommunity)

Return the average behaviour by location in a lattice community.
"""
function characterize_bylocation(x::AbstractDiscretePlanarCommunity)
  out = zeros(x.size, x.size)
  speakers_bycell = zeros(x.size, x.size)

  for s in 1:length(x.census)
    speaker = x.census[s]
    sx = x.locations[s].x
    sy = x.locations[s].y
    out[sx, sy] += characterize(speaker)
    speakers_bycell[sx, sy] += 1
  end

  out ./ speakers_bycell
end


"""
    characterize(x::MomentumSelector)

Characterize the state of a `MomentumSelector`, i.e. return the grammar
probability.
"""
function characterize(x::MomentumSelector)
  x.grammar.x
end


"""
    characterize_momentum(x::MomentumSelector)

Characterize the normalized momentum term of a `MomentumSelector`.
"""
function characterize_momentum(x::MomentumSelector)
  (x.gamma_grammar.x - x.grammar.x)/x.mmax
end


"""
    characterize_momentum_bylocation(x::AbstractDiscretePlanarCommunity)

Return the average normalized momentum by location in a lattice community.
"""
function characterize_momentum_bylocation(x::AbstractDiscretePlanarCommunity)
  out = zeros(x.size, x.size)
  speakers_bycell = zeros(x.size, x.size)

  for s in 1:length(x.census)
    speaker = x.census[s]
    sx = x.locations[s].x
    sy = x.locations[s].y
    out[sx, sy] += characterize_momentum(speaker)
    speakers_bycell[sx, sy] += 1
  end

  out ./ speakers_bycell
end


