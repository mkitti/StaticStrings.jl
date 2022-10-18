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

### Getting Started

To start we create a basic static string of fixed size. A normal Julia `String` has variable size. "Hello world!" has 12 ASCII characters and thus 12 UTF-8 code units. Using the `static"Hello world!"` static string macro let's us easily construct the string of type `StaticString{12}`. Like a StaticArray from StaticArrays.jl, the UTF-8 codeunit capacity is specified in the type. Internally, `StaticString{12}` just wraps a `NTuple{12,UInt8}`. Below we see the string is printed as `static"Hello World!"12` where the trailing number indicates the number of code units. 

```julia
julia> using StaticStrings

julia> static"Hello world!"
static"Hello world!"12

julia> static"Hello world!" |> typeof
StaticString{12}
```

The number of code units can also be explicitly specified. If the specified length is longer than needed, additional NUL bytes will be appended. Printing the string will stop at the first NUL byte.

```julia
julia> static"Hello world!"12
static"Hello world!"12

julia> static"Hello world!"31
static"Hello world!\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"31

julia> print(static"Hello world!"31, static" Bye!")
Hello world! Bye!
```

### Calling C code

One particular application for these fixed length strings is calling C code. The `CStaticString` provides a variant that ensures a terminal NUL byte and ensures that no terminal NUL bytes are contained in the string.

```julia
julia> cs = cstatic"Hello world!\n"
cstatic"Hello world!"13

julia> ccall(:printf, Cint, (Ptr{Cchar},), cs)
Hello world!
13

julia> ccall(:printf, Cint, (Ptr{CStaticString{13}},), Ref(cs))
Hello world!
13
```

### Changing the padding

Another variant is the `PaddedStaticString`. The last code unit in the provided string is used as padding. We can see the effect of the padding by converting it to a `StaticString`.

```julia
julia> ps = padded"Hello "20
padded"Hello "20

julia> StaticString(ps)
static"Hello               "20
```

### Compact Array Layout

One advantage of `StaticString` over `String` is that the fixed size allows for a simple and compact array layout. Unlike InlineStrings.jl, the strings can be any fixed size.

```julia
julia> strings = StaticString{5}["Hello", "Bye"]
2-element Vector{StaticString{5}}:
 static"Hello"5
 static"Bye\0\0"5

julia> push!(strings, "Hola")
3-element Vector{StaticString{5}}:
 static"Hello"5
 static"Bye\0\0"5
 static"Hola\0"5

julia> unsafe_load(pointer(strings,1))
static"Hello"5

julia> unsafe_load(pointer(strings,2))
static"Bye\0\0"5

julia> unsafe_load(pointer(strings,3))
static"Hola\0"5

julia> sizeof(strings)
15
```

## Status

As of September 2022, this is currently under initial development.

## Related Packages

1. [InlineStrings.jl](https://github.com/JuliaStrings/InlineStrings.jl) implements a form of static strings using primitives. This is facilitates high performance parsing.
2. [StaticTools.jl](https://github.com/brenhinkeller/StaticTools.jl) provides tools for static compilation. The package provides a different implementation of StaticString.

The ability of StaticStrings.jl to compose with these packages is being evaluated. Initial tests have been written.
