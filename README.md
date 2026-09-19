# StaticStrings.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://mkitti.github.io/StaticStrings.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://mkitti.github.io/StaticStrings.jl/dev/)
[![Build Status](https://github.com/mkitti/StaticStrings.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/mkitti/StaticStrings.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/mkitti/StaticStrings.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/mkitti/StaticStrings.jl)

Fixed-length strings wrapping a `NTuple` for Julia.

## Introduction

StaticStrings.jl implements `AbstractString` subtypes backed by an `NTuple{N, UInt8}`. `N` is the backing capacity in bytes, not necessarily the logical content length.

The concrete subtypes of `AbstractStaticString` are as follows.
1. `StaticString{N}`, with a capacity of `N` UTF-8 code units, uses all `N` code units as logical content, including all NULs and any constructor-added padding.
2. `SubStaticString{N,R}`, with integer unit range type `R`, has exactly the bytes selected by its range (for example, `2:5`), including any NULs.
3. `CStaticString{N}` ends before its first NUL, or after all `N` stored bytes if none is present. An extra safety NUL guarantees termination for C calls.
4. `PaddedStaticString{N, PAD}` excludes only trailing `PAD` bytes. Internal occurrences of `PAD` remain content. NULs remain content unless they occur at the end and `PAD == 0`.

String operations and conversions use the logical content defined above, while `Tuple(s)` exposes the full backing storage. Constructors reject content that exceeds the destination capacity.

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

The number of code units can also be explicitly specified. If the specified length is longer than needed, additional NUL bytes become part of the content. Both `print` and `write` include those bytes, even though a terminal may not display them.

```julia
julia> static"Hello world!"12
static"Hello world!"12

julia> static"Hello world!"31
static"Hello world!\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"31

julia> ncodeunits(static"Hello world!"31)
31
```

### Calling C code

One application is calling C code. `CStaticString` guarantees NUL termination and treats the first NUL as the end of its content.

```julia
julia> cs = cstatic"Hello world!\n"
cstatic"Hello world!\n"13

julia> ccall(:printf, Cint, (Ptr{Cchar},), cs)
Hello world!
13

julia> ccall(:printf, Cint, (Ptr{CStaticString{13}},), Ref(cs))
Hello world!
13
```

### Changing the padding

Another variant is `PaddedStaticString`. The last code unit in the nonempty literal is used as padding. Logical content ends at the last code unit that differs from the padding value. Capacity defaults to the unescaped literal's byte length, including padding. Add a suffix, such as `padded"Hello "20`, to specify it explicitly.

```julia
julia> ps = padded"Hello "
padded"Hello "6

julia> ncodeunits(ps)
5
```

`padded"Hello\0"` stores six bytes, including its NUL terminator, without an extra safety byte. Unlike `CStaticString`, it excludes only trailing NULs and retains embedded NULs as content.

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

For fixed-capacity text whose length varies, use `SubStaticString{N}`:

```julia
julia> strings = [SubStaticString{5}("Hello")];

julia> push!(strings, "Bye")
2-element Vector{SubStaticString{5, Base.OneTo{Int64}}}:
 substatic"Hello"5
 substatic"Bye"5

julia> ncodeunits.(strings)
2-element Vector{Int64}:
 5
 3
```

The default range is `Base.OneTo{Int}` and counts bytes, not characters. The inferred vector has a concrete element type. A typed literal such as `SubStaticString{5}["Hello"]` instead retains the partially specified element type.

## Bytes and Objects

`write(io, s)` writes only logical content for every type, including `CStaticString`. It does not append a C terminator. Write a terminator explicitly with `write(io, s, '\0')` when a wire format requires one. Write the backing bytes explicitly with `write(io, collect(Tuple(s)))`. Use `Serialization.serialize` and `deserialize` to preserve the Julia object's type, capacity, backing bytes, and range.

`read(io, T)` for a fixed-capacity type, such as `read(io, CStaticString{N})`, reads exactly `N` backing bytes. `read(io, CStaticString)` reads until the first NUL, consuming the terminator. Pair it with `write(io, s, '\0')` to round-trip C-string content, not backing storage.

For C calls, `Ptr{UInt8}` and `Ptr{Cchar}` conversions point to the start of logical content and require an explicit byte count unless the type is `CStaticString`, which guarantees termination. Outside `ccall`, preserve the owner returned by `Base.cconvert` with `GC.@preserve` while using `Base.unsafe_convert`. `Cstring` conversion creates a terminated `String` and rejects embedded NULs.

## Status

As of September 2022, this is currently under initial development.

## Related Packages

1. [InlineStrings.jl](https://github.com/JuliaStrings/InlineStrings.jl) implements a form of static strings using primitives. This is facilitates high performance parsing.
2. [StaticTools.jl](https://github.com/brenhinkeller/StaticTools.jl) provides tools for static compilation. The package provides a different implementation of StaticString.

The ability of StaticStrings.jl to compose with these packages is being evaluated. Initial tests have been written.
