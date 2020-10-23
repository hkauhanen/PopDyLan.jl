# Speaker reference

## Speaker types and constructors

```@docs
EmptySpeaker
MomentumSelector
MomentumSelector(alpha::Float64, gamma::Float64, b::Float64, T::Int, x0::Float64)
NeutralVariationalLearner
NeutralVariationalLearner(gamma::Float64)
NeutralVariationalLearner(gamma::Float64, p0::Float64)
VariationalLearner
VariationalLearner(gamma::Float64, a1::Float64, a2::Float64)
VariationalLearner(gamma::Float64, a1::Float64, a2::Float64, p0::Float64)
```


## Speaker functions

```@docs
act!
speak
```
