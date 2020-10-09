# Philosophy

The particular philosophy adopted by PopDyLan toward modelling the dynamics of language can be understood through interactions and containment relations between three types of types: communities, speakers and grammars. In brief:

!!! info
    A **community** is a container of **speakers**, who are containers of **grammars**.

Technically, communities are composite types derived from the abstract `AbstractCommunity` type or one of its abstract descendants. For example, `MultiplexCommunity` is a particular concrete implementation of `AbstractNetworkCommunity`. Similarly, speakers are composite types descending from `AbstractSpeaker`, and grammars are composite types descending from `AbstractGrammar`.


## The nature of communities

Every community object is required to minimally implement the following:

* A field named `census`, which is an Array of `AbstractSpeaker` objects. The census provides each speaker with a unique identifier, namely its array index, at any given point in time.
* A function `inject!(x,y)`, which inserts speaker object `x` into community `y`.
* A function `eject!(x,y)`, which removes speaker with index `x` in the census of community `y`.
* A function `rendezvous!(x)`, which triggers some sort of encounter between speakers in community `x` (details of implementation to be left to the nature of the community).

Particular types of communities will implement further fields and functions. For example, all network communities (descendants of `AbstractNetworkCommunity`) must have methods for connecting and disconnecting speakers (`connect!` and `disconnect!` functions). The specific requirements for implementing particular abstract types are detailed in the documentation for each abstract type.

!!! warning
    Speaker identifiers in the census of a community are unique *modulo* time only. If a speaker is removed (i.e. `eject!`ed) from a community, all indices greater than the index of this speaker are shifted to the left by one. If permanent one-to-one speaker identification is required, this can be accomplished through external bookkeeping (see [example](FIXME)).


## The nature of speakers

As explained above, all speaker types descend from one of the abstract speaker types. Every speaker object is required to implement at least:

* A field named `grammar` of a type that descends from `AbstractGrammar`.
* A function `act!(x,y)` which specifies how a speaker `x` acts on another speaker `y` (both of the same type).


## Rendezvous and actions

In PopDyLan, speaker interactions normally arise through calls to a **rendezvous** function implemented in the community whose members those speakers are. This rendezvous function then calls upon **action** functions implemented by the speakers which, in turn, may modify the grammars carried by the speakers.

For example, suppose we have a community `x` whose implementation of the function `rendezvous!(x)` (see above) is to pick two speakers from the census at random and to make both of these speakers act upon each other, if some condition *C* is satisfied (for example, the probability of interaction of these particular speakers). Calling `rendezvous!(x)` would then first check for *C*, and, if satisfied, proceed to call both `act!(a,b)` and `act!(b,a)`, where `a` and `b` are the two randomly chosen speakers. The effect of the action functions depends on the types of the speakers: supposing, for example, that both speakers are utterance selectors, speaker `a` acting on `b` then has the effect of `a` producing a number of utterances and `b` updating its grammar based on that action. In general, actions are asymmetric, i.e. `act!(a,b)` cannot be assumed to have the same effect as `act!(b,a)`.

!!! info
    Rendezvous functions are used to prompt speakers to act upon each other. Whether an action *in fact* occurs may depend on the satisfaction of some set of conditions, depending on the nature of the community and the speakers involved. When an action function is called, an action is guaranteed to occur. Actions, however, are asymmetric: in general, `act!(a,b)` cannot be assumed to have the same effects as `act!(b,a)`.


## The type hierarchies

The following interactive graphs display the hierarchies of community, speaker and grammar types in PopDyLan. Click on a node to expand/fold.

### Communities

```@raw html
<div style="width: 200%">
```
```@example
using D3TypeTrees # hide
import PopDyLan # hide
TypeTree(PopDyLan.AbstractCommunity) # hide
```
```@raw html
</div>
```

### Speakers

```@raw html
<div style="width: 200%">
```
```@example
using D3TypeTrees # hide
import PopDyLan # hide
TypeTree(PopDyLan.AbstractSpeaker) # hide
```
```@raw html
</div>
```

### Grammars

```@raw html
<div style="width: 200%">
```
```@example
using D3TypeTrees # hide
import PopDyLan # hide
TypeTree(PopDyLan.AbstractGrammar) # hide
```
```@raw html
</div>
```
