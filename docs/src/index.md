# PopDyLan.jl

PopDyLan is a [Julia](https://julialang.org/) package for exploring the **population dynamics of language** through agent-based simulations. It implements several common models of language acquisition and use (such as utterance selection, variational learning) in a variety of community structures ranging from simple pools of speakers to spatial populations and multiplex networks. To facilitate extension of the library with custom types and functions, minimal restrictions are placed on what objects may interface with what objects.

The [Getting started](@ref) provides installation instructions and a simple example of usage. The [Philosophy](@ref) page explains the modelling philosophy of PopDyLan in detail. A number of further use cases are illustrated under [Examples](@ref). The [Community reference](@ref), [Speaker reference](@ref) and [Grammar reference](@ref) pages document all types and functions available to the end user. The [Auxiliary reference](@ref) documents a number of auxiliary functions which assist in setting up simulations and recording their output.

!!! warning
    PopDyLan is in active development, and in its very early stages. Major changes to the architecture are possible, so expect things to break.

PopDyLan.jl is free and open-source software, licensed under the [MIT license](https://opensource.org/licenses/MIT).


## I've found a bug!

PopDyLan is maintained by [Henri Kauhanen](https://henr.in/). If you find a bug, please [file an issue](FIXME) (preferred) or send Henri an email.


## Acknowledgements

Preparation of this software was made possible in part by financial support from the Federal Ministry of Education and Research (BMBF) and the Baden-Württemberg Ministry of Science as part of the Excellence Strategy of the German Federal and State Governments.


## Features

PopDyLan.jl currently implements:

- Momentum-based utterance selection
- Zipfian lattice communities


## Roadmap

To be implemented are at least the following:

- Variational learning
- Utterance selection
- Network community types
- TLA
- Cue-based learning (Lightfoot, Mitchener)
- Types for more complex grammars (as one would need to model syntactic change, for example)
- Replicator–mutator dynamics
- The frequency matcher agent from Kauhanen 2017
- Kauhanen's and Michaud's well-behavedness measures
- Exemplar dynamics (learners/speakers/listeners, as well as representation of the relevant exemplar grammars)
