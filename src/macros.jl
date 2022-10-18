"""
    static"string"[N]

Create a [`StaticString`](@ref) from "string".
Optionally, specify the number of codeunits, `N`.

# Examples
```jldoctest
julia> static"großartig"
static"großartig"10

julia> static"verehrungswürdig"20
static"verehrungswürdig\\0\\0\\0"20
```
"""
macro static_str(ex)
    s = StaticString(unescape_string(ex))
    quote
        $s
    end
end
macro static_str(ex, N)
    s = StaticString{N}(unescape_string(ex))
    quote
        $s
    end
end
_macroname(::Type{<:StaticString}) = "static"

"""
    substatic"string"[N]

Create a [`SubStaticString`](@ref) from "string".
Optionally, specify the number of codeunits, `N`.
The result will be a `SubStaticString{N}` but the codeunits used will be those
of the original string.

# Examples
```jldoctest
julia> substatic"Як ти?"
substatic"Як ти?"10

julia> substatic"Як ти?"256
substatic"Як ти?"256
```
"""
macro substatic_str(ex)
    s = SubStaticString(unescape_string(ex))
    quote
        $s
    end
end
macro substatic_str(ex, N)
    s = unescape_string(ex)
    n = ncodeunits(s)
    if n <= typemax(UInt8)
        n = UInt8(n)
    end
    s = SubStaticString{N}(s, n)
    quote
        $s
    end
end
_macroname(::Type{<:SubStaticString}) = "substatic"

"""
    cstatic"string"[N]

Create a [`CStaticString`](@ref) from "string".
Optionally, specify the number of codeunits, `N`.

# Examples
```jldoctest
julia> cstatic"Orada mısın"
cstatic"Orada mısın"13

julia> cstatic"Orada mısın"25
cstatic"Orada mısın"25

julia> ccall(:jl_printf, Cint, (Ptr{Nothing}, Ptr{Cchar},), stdout isa IOContext ? stdout.io : stdout, cstatic"Orada mısın\\n"25)
Orada mısın
14
```
"""
macro cstatic_str(ex)
    s = CStaticString(unescape_string(ex))
    quote
        $s
    end
end
macro cstatic_str(ex, N)
    s = CStaticString{N}(unescape_string(ex))
    quote
        $s
    end
end
_macroname(::Type{<:CStaticString}) = "cstatic"

"""
    padded"string[PAD]"N

Create a [`PaddedStaticString`](@ref) of `N` codeunits from "string".
The last codeunit in the provided string becomes the `PAD`.

# Examples
```jldoctest
julia> padded"私は元気です。 ありがとうございました。 "64
padded"私は元気です。 ありがとうございました。 "64

julia> padded"私は元気です。 ありがとうございました。 "64 |> StaticString
static"私は元気です。 ありがとうございました。      "64
```
"""
macro padded_str(ex, N)
    s = unescape_string(ex)
    pad = codeunits(s)[end]
    s = PaddedStaticString{N, pad}(s)
    quote
        $s
    end
end
_macroname(::Type{<:PaddedStaticString}) = "padded"

"""
    @substatic string[a:b]

Create a [`SubStaticString`](@ref) by selecting a range of codeunits. This differs
from normal indexing which occurs on characters.
"""
macro substatic(ex)
    @assert(ex.head == :ref, "Expression is of type $(ex.head) rather than :ref")
    :(SubStaticString($(esc(ex.args[1])), $(esc(ex.args[2]))))
end
