"""
    static"string"[N]

Create a [`StaticString`](@ref) from "string".
Optionally, specify the number of codeunits, `N`.

# Examples
```jldoctest
julia> static"großartig"
Static"großartig"10

julia> static"verehrungswürdig"20
Static"verehrungswürdig\\0\\0\\0"20
```
"""
macro static_str(ex)
    s = unescape_string(ex)
    quote
        StaticString($s)
    end
end
macro static_str(ex, N)
    s = unescape_string(ex)
    quote
        StaticString{$N}($s)
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
subttatic"Як ти?"256
```
"""
macro substatic_str(ex)
    s = unescape_string(ex)
    quote
        SubStaticString($s)
    end
end
macro substatic_str(ex, N)
    s = unescape_string(ex)
    n = ncodeunits(s)
    if n <= typemax(UInt8)
        n = UInt8(n)
    end
    quote
        SubStaticString{$N}($s, $n)
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

julia> ccall(:jl_printf, Cint, (Ptr{Nothing}, Ptr{Cchar},), stdout isa IOContext ? stdout.io : stdout, CStatic"Orada mısın\\n"25)
Orada mısın
14
```
"""
macro cstatic_str(ex)
    s = unescape_string(ex)
    quote
        CStaticString($s)
    end
end
macro cstatic_str(ex, N)
    s = unescape_string(ex)
    quote
        CStaticString{$N}($s)
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
    quote
        PaddedStaticString{$N, $pad}($s)
    end
end
_macroname(::Type{<:PaddedStaticString}) = "padded"


