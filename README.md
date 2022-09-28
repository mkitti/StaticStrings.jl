# StaticStrings.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://mkitti.github.io/StaticStrings.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://mkitti.github.io/StaticStrings.jl/dev/)
[![Build Status](https://github.com/mkitti/StaticStrings.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/mkitti/StaticStrings.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/mkitti/StaticStrings.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/mkitti/StaticStrings.jl)

Fixed-length strings wrapping a `NTuple` for Julia.

## Introduction

StaticStrings.jl implements several `AbstractString` subtypes that wrap a `NTuple{N,UInt8}`. An `AbstractStaticString` is a `AbstractString` with `N` codeunits.

The concrete subtypes of `AbstractStaticString` are as follows.
1. `StaticString{N}` is just a wrapper of a `NTuple{N,UInt8}` of exactly `N` codeunits.
2. `CStaticString{N}` is similar to a `StaticString` but requires all the NUL bytes to be terminal codeunits. The struct also contains an extra terminal NUL.

## Usage

```julia
julia> using StaticStrings

julia> N"Hello World!"
"Hello World!"

julia> N"Hello World!" |> typeof
StaticString{12}

julia> CN"Hello\0"
"Hello\0"

julia> N"Hello World!" |> String
"Hello World!"

julia> N"Hello World!" |> String |> typeof
String

julia> String[N"Hello"]
1-element Vector{String}:
 "Hello"

julia> push!(StaticString[N"Hello"], "Bye")
2-element Vector{StaticString}:
 "Hello"
 "Bye"
```

## Status

As of September 2022, this is currently under initial development.
