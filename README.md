# StaticStrings.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://mkitti.github.io/StaticStrings.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://mkitti.github.io/StaticStrings.jl/dev/)
[![Build Status](https://github.com/mkitti/StaticStrings.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/mkitti/StaticStrings.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/mkitti/StaticStrings.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/mkitti/StaticStrings.jl)

Fixed-length strings wrapping a `NTuple` for Julia.

## Introduction

StaticStrings.jl implements several `AbstractString` subtypes that wrap a `NTuple{N,UInt8}`. An `AbstractStaticString` is a `AbstractString` with `N` codeunits.

The concrete subtypes of `AbstractStaticString` are as follows.
1. `StaticString{N}` is just a wrapper of a `NTuple{N,UInt8}` of exactly `N` codeunits, padded with `\0`, nul, bytes.
2. `SubStaticString{N, R}` is a wrapper of a `NTuple{N,UInt8}` of up to `N` codeunits, with a unit range indicating a subset of codeunits.
3. `CStaticString{N}` is similar to a `StaticString` but requires all the NUL bytes to be terminal codeunits. The struct also contains an extra terminal NUL.
4. `PaddedStaticString{N,PAD}` is siimlar to `StaticString` but is padded with an arbitrary byte codeunit.

## Usage

```julia
julia> using StaticStrings

julia> static"Hello world!"
static"Hello world!"12

julia> static"Hello world!" |> typeof
StaticString{12}

julia> cstatic"Hello world!"
cstatic"Hello world!"12

julia> ccall(:printf, Cint, (Ptr{Cchar},), cs)
Hello world!
13

julia> ccall(:printf, Cint, (Ptr{CStaticString{13}},), Ref(cs))
Hello world!
13

julia> padded"Hello "20
Padded"Hello "20

julia> ps = padded"Hello "20
padded"Hello "20

julia> StaticString(ps)
static"Hello               "20

julia> strs = StaticString{5}["Hello"]
1-element Vector{StaticString{5}}:
 static"Hello"5

julia> push!(strs, "Bye")
2-element Vector{StaticString{5}}:
 static"Hello"5
 static"Bye"5
```

## Status

As of September 2022, this is currently under initial development.

## Related Packages

1. [InlineStrings.jl](https://github.com/JuliaStrings/InlineStrings.jl) implements a form of static strings using primitives. This is facilitates high performance parsing.
2. [StaticTools.jl](https://github.com/brenhinkeller/StaticTools.jl) provides tools for static compilation. The package provides a different implementation of StaticString.

The ability of StaticStrings.jl to compose with these packages is being evaluated. Initial tests have been written.
