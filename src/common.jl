"""
A 2D point of type `T`; has fields `x` and `y`, both of type `T`.
A frequent use case is `Point{Int}` for a point in the two-dimensional
Cartesian product of integers.
"""
struct Point{T}
  x::T
  y::T
end


"""
    zipf(N::Int, s::Float64)

Zipf's Law for `N` elements and scaling exponent `s`, i.e. the probability mass function

```math
f(k; s, N) = H_{N,s}^{-1} k^{-s}
```

for ``k = 1, \\dots , N``, where ``H_{N,s}`` is the generalized harmonic 
number used for normalization.
"""
function zipf(N::Int, s::Float64)
  out = 1 ./ ((1:N) .^ s)
  out/sum(out)
end


"""
    manhattan(x::Point{Int}, y::Point{Int})

Find the Manhattan distance between two integer points.
"""
function manhattan(x::Point{Int}, y::Point{Int})
  abs(x.x - y.x) + abs(x.y - y.y)
end


"""
    chebyshev(x::Point{Int}, y::Point{Int})

Find the Chebyshev distance between two integer points.
"""
function chebyshev(x::Point{Int}, y::Point{Int})
  max(abs(x.x - y.x), abs(x.y - y.y))
end
