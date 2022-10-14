```@meta
CurrentModule = StaticStrings
```

# StaticStrings

Documentation for [StaticStrings](https://github.com/mkitti/StaticStrings.jl).

Fixed-length strings wrapping a `NTuple` for Julia.

## Introduction

StaticStrings.jl implements several `AbstractString` subtypes that wrap a `NTuple{N,UInt8}`. An `AbstractStaticString` is a `AbstractString` with `N` codeunits.

The concrete subtypes of `AbstractStaticString` are as follows.
1. `StaticString{N}` is a wrapper of a `NTuple{N,UInt8}` of exactly `N` codeunits, padded with `\0`, nul, bytes.
2. `SubStaticString{N, R <: AbstractUnitRange}` is a wrapper of a `NTuple{N,UInt8}` of up to `N` codeunits, with a unit range indicating a subset of codeunits.
3. `CStaticString{N}` is similar to a `StaticString` but requires all the NUL bytes to be terminal codeunits. The struct also contains an extra terminal NUL.
4. `PaddedStaticString{N,PAD}` is siimlar to `StaticString` but is padded with an arbitrary byte codeunit.

## Usage

```julia
julia> using StaticStrings

julia> static"Hello world!"
static"Hello world!"12

julia> static"Hello world!" |> typeof
StaticString{12}

julia> cs = cstatic"Hello world!\n"
cstatic"Hello world!\n"13

julia> ccall(:printf, Cint, (Ptr{Cchar},), cs)
Hello world!
13

julia> ccall(:printf, Cint, (Ptr{CStaticString{13}},), Ref(cs))
Hello world!
13

julia> padded"Hello "20
padded"Hello "20

julia> ps = padded"Hello "20
padded"Hello "20

julia> StaticString(ps)
static"Hello               "20

julia> push!(StaticString["Hello"], "Bye")
2-element Vector{StaticString}:
 static"Hello"5
 static"Bye"5
```

```@index
```

```@docs
StaticStrings
AbstractStaticString
StaticString
@static_str
SubStaticString
@substatic_str
CStaticString
@cstatic_str
PaddedStaticString
@padded_str
data
pad
```
