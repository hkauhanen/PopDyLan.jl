# Getting started

## Installation

Run the following from the Julia REPL to install the latest stable version of PopDyLan:

```julia
using Pkg
#FIXME
```

## Simple example: a pool of people

First, we load PopDyLan:

```@example simple; continued = true
using PopDyLan
```

To illustrate some of the most basic functionality of PopDyLan, let's set up a "pool community". This is a fully-mixing finite community of speakers, i.e. everyone is connected to everyone.

```@example simple; continued = true
com = PoolCommunity()
```

By default, the community starts empty, so let us add some speakers into it. In this case, we use 10 `MomentumSelector`s, i.e. speakers defined by the momentum-based utterance selection model (Stadler et al. 2016).

```@example simple; continued = true
for i in 1:100
  spk = MomentumSelector(0.01, 0.04, 2.0, 5, 0.1)
  inject!(spk, com)
end
```

The `inject!` function takes care of inserting the speakers into the community. Each speaker is constructed using the `MomentumSelector` constructor which takes the following arguments: learning rate $\alpha$, short-term memory smoothing factor $\gamma$, momentum bias $b$, number of utterances per interaction $T$, and initial frequency of the incoming variant $x_0$ (see Stadler et al. 2016 for the definition of these). Here, we set these at the values $\alpha = 0.01$, $\gamma = 0.04$, $b = 2.0$, $T = 5$ and $x_0 = 0.1$ for all speakers.

The type `PoolCommunity`, like most community types, has a `rendezvous!` function which samples two speakers from the community at random and tries a pairwise interaction between them. In this case, the rendezvous function calls an `act!` function on both speakers, so that each speaker speaks in the interaction. Let's conduct 100,000 random rendezvous (altogether 200,000 speaking events):

```@example simple; continued = true
for i in 1:100_000
  rendezvous!(com)
end
```

Now that's well and good, but since we didn't keep track of the state of the community, we don't really know what happened. A simple way of implementing tracking in a community of speakers whose grammars consist of a probability distribution over two variants is by using the `characterize` function. This reports the average probability of the incoming variant across the community. This can be stored in an array, for example.

Let's sample the community's state every 100 iterations. All in all, we replace the above code block with:

```@example simple; continued = true
diachrony = Array{Float64}(undef, 1000)
for i in 1:1000
  for j in 1:100
    rendezvous!(com)
  end
  diachrony[i] = characterize(com)
end
```

The `diachrony` array now contains the history of the community over 100,000 iterations, sampled at 100-iteration intervals. We can, for example, plot it:

```@example simple; continued = false
using Plots
plot(1:length(diachrony), diachrony)
savefig("simple-plot.png"); nothing # hide
```

![](simple-plot.png)

Putting it all together, we have the following little script:

```julia
# Set up a pool community
com = PoolCommunity()

# Add some speakers
for i in 1:100
  spk = MomentumSelector(0.01, 0.04, 2.0, 5, 0.1)
  inject!(spk, com)
end

# Interact, recording state of community every 100 iterations
diachrony = Array{Float64}(undef, 1000)
for i in 1:1000 
  for j in 1:100
    rendezvous!(com)
  end   
  diachrony[i] = characterize(com)
end

# Plot history of community
using Plots
plot(1:length(diachrony), diachrony)
```


## Reference

Stadler, K., Blythe, R. A., Smith, K. & Kirby, S. (2016) Momentum in language
change: a model of self-actuating s-shaped curves. *Language Dynamics and Change*,
6, 171–198. <https://doi.org/10.1163/22105832-00602005>
