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

julia> Static"Hello world!"
Static"Hello world!"12

julia> Static"Hello world!" |> typeof
StaticString{12}

julia> cs = CStatic"Hello world!"
CStatic"Hello world!"12

julia> ccall(:printf, Cint, (Ptr{Cchar},), cs)
Hello world!
13

julia> ccall(:printf, Cint, (Ptr{CStaticString{13}},), Ref(cs))
Hello world!
13

julia> Padded"Hello "20
Padded"Hello "20

julia> ps = Padded"Hello "20
Padded"Hello "20

julia> StaticString(ps)
Static"Hello               "20

julia> push!(StaticString["Hello"], "Bye")
2-element Vector{StaticString}:
 Static"Hello"5
 Static"Bye"5
```

```@index
```

```@docs
StaticStrings
AbstractStaticString
StaticString
@Static_str
SubStaticString
@SubStatic_str
CStaticString
@CStatic_str
PaddedStaticString
@Padded_str
data
pad
```
