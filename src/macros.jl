"""
    Static"string"[N]

Create a [`StaticString`](@ref) from "string".
Optionally, specify the number of codeunits, `N`.

# Examples
```jldoctest
julia> Static"großartig"
Static"großartig"10

julia> Static"verehrungswürdig"20
Static"verehrungswürdig\\0\\0\\0"20
```
"""
macro Static_str(ex)
    s = unescape_string(ex)
    quote
        StaticString($s)
    end
end
macro Static_str(ex, N)
    s = unescape_string(ex)
    quote
        StaticString{$N}($s)
    end
end
_macroname(::Type{<:StaticString}) = "Static"

"""
    SubStatic"string"[N]

Create a [`SubStaticString`](@ref) from "string".
Optionally, specify the number of codeunits, `N`.

# Examples
```jldoctest
julia> SubStatic"Як ти?"
SubStatic"Як ти?"10

julia> SubStatic"Як ти?"256
SubStatic"Як ти?"256
```
"""
macro SubStatic_str(ex)
    s = unescape_string(ex)
    quote
        SubStaticString($s)
    end
end
macro SubStatic_str(ex, N)
    s = unescape_string(ex)
    n = ncodeunits(s)
    if n <= typemax(UInt8)
        n = UInt8(n)
    end
    quote
        SubStaticString{$N}($s, $n)
    end
end
_macroname(::Type{<:SubStaticString}) = "SubStatic"

"""
    CStatic"string"[N]

Create a [`CStaticString`](@ref) from "string".
Optionally, specify the number of codeunits, `N`.

# Examples
```jldoctest
julia> CStatic"Orada mısın"
CStatic"Orada mısın"13

julia> CStatic"Orada mısın"25
CStatic"Orada mısın"25

julia> ccall(:jl_printf, Cint, (Ptr{Nothing}, Ptr{Cchar},), stdout isa IOContext ? stdout.io : stdout, CStatic"Orada mısın\\n"25)
Orada mısın
14
```
"""
macro CStatic_str(ex)
    s = unescape_string(ex)
    quote
        CStaticString($s)
    end
end
macro CStatic_str(ex, N)
    s = unescape_string(ex)
    quote
        CStaticString{$N}($s)
    end
end
_macroname(::Type{<:CStaticString}) = "CStatic"

"""
    Padded"string[PAD]"N

Create a [`PaddedStaticString`](@ref) of `N` codeunits from "string".
The last codeunit in the provided string becomes the `PAD`.

# Examples
```jldoctest
julia> Padded"私は元気です。 ありがとうございました。 "64
Padded"私は元気です。 ありがとうございました。 "64

julia> Padded"私は元気です。 ありがとうございました。 "64 |> StaticString
Static"私は元気です。 ありがとうございました。      "64
```
"""
macro Padded_str(ex, N)
    s = unescape_string(ex)
    pad = codeunits(s)[end]
    quote
        PaddedStaticString{$N, $pad}($s)
    end
end
_macroname(::Type{<:PaddedStaticString}) = "Padded"


