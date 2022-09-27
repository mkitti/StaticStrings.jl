# NStrings.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://mkitti.github.io/NStrings.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://mkitti.github.io/NStrings.jl/dev/)
[![Build Status](https://github.com/mkitti/NStrings.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/mkitti/NStrings.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/mkitti/NStrings.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/mkitti/NStrings.jl)

Fixed-length strings wrapping a `NTuple` for Julia.

## Introduction

NStrings.jl implements several `AbstractString` subtypes that wrap a `NTuple{N,UInt8}`. An `AbstractNString` is a `AbstractString` with `N` codeunits.

The concrete subtypes of `AbstractNString` are as follows.
1. `NString{N}` is just a wrapper of a `NTuple{N,UInt8}` of exactly `N` codeunits.
2. `CNString{N}` is similar to a `NString` but requires that the Nth codeunit and only the Nth codeunit be a NUL (`0x00`) byte.
3. `NMString{N,M}` is a wrapper of `NTuple{M,UInt8}` but only represents `N` codeunits
4. `CNMString{N,M}` is a wrapper of `NTuple{M,UInt8}` but only represents `N` codeunits and has a NUL (`0x00`) byte at codeunit `N+1`

## Usage

```julia
julia> using NStrings

julia> N"Hello World!"
"Hello World!"

julia> N"Hello World!" |> typeof
NString{12}

julia> CN"Hello\0"
"Hello\0"

julia> N"Hello World!" |> String
"Hello World!"

julia> N"Hello World!" |> String |> typeof
String

julia> String[N"Hello"]
1-element Vector{String}:
 "Hello"

julia> push!(NString[N"Hello"], "Bye")
2-element Vector{NString}:
 "Hello"
 "Bye"
```

## Status

As of September 2022, this is currently under initial development.
