```@meta
CurrentModule = StaticStrings
```

# StaticStrings

Documentation for [StaticStrings](https://github.com/mkitti/StaticStrings.jl).

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

julia> ps = padded"Hello "
padded"Hello "6

julia> ncodeunits(ps)
5

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

`padded"..."` uses the last code unit of its nonempty literal as padding and infers capacity from the unescaped byte length. Use a suffix, such as `padded"Hello "20`, for explicit capacity. `padded"Hello\0"` stores six bytes, including its NUL terminator, without an extra safety byte. Unlike `CStaticString`, it excludes only trailing NULs and retains embedded NULs as content.

`SubStaticString{N}(str)` preserves `ncodeunits(str)` in a `Base.OneTo{Int}` range, padding only the backing storage. The inferred vector above has a concrete element type. `SubStaticString{5}["Hello"]` instead keeps a partially specified element type.

## Bytes and Objects

`write(io, s)` writes logical content only, even for `CStaticString`. For a NUL-delimited wire format, write the terminator explicitly with `write(io, s, '\0')`. For raw backing bytes, use `write(io, collect(Tuple(s)))`. Use `Serialization.serialize` and `deserialize` to preserve the Julia object's type, capacity, storage, and range.

`read(io, T)` for a fixed-capacity type, such as `read(io, CStaticString{N})`, reads exactly `N` backing bytes. `read(io, CStaticString)` reads until the first NUL, consuming the terminator. Pair it with `write(io, s, '\0')` to round-trip C-string content, not backing storage.

For C calls, `Ptr{UInt8}` and `Ptr{Cchar}` point to the start of logical content. Pass an explicit byte count unless using `CStaticString`, which guarantees NUL termination. Outside `ccall`, preserve the owner returned by `Base.cconvert` with `GC.@preserve` while using `Base.unsafe_convert`. `Cstring` conversion creates a terminated `String` and rejects embedded NULs.

```@index
```

```@docs
StaticStrings
AbstractStaticString
StaticString
@static_str
SubStaticString
@substatic_str
@substatic
codeunits(::SubStaticString)
CStaticString
@cstatic_str
PaddedStaticString
@padded_str
Tuple(::AbstractStaticString)
pad
```

## Internal Functions

```@docs
StaticStrings.write_codeunits
```
