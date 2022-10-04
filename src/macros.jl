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
    Short"string"[N]

Create a [`ShortStaticString`](@ref) from "string".
Optionally, specify the number of codeunits, `N`.

# Examples
```jldoctest
julia> Short"Доброе утро"
Short"Доброе утро"21

julia> Short"Добрый вечер"25
Short"Добрый вечер"25
```
"""
macro Short_str(ex)
    s = unescape_string(ex)
    quote
        ShortStaticString($s)
    end
end
macro Short_str(ex, N)
    s = unescape_string(ex)
    n = ncodeunits(s)
    quote
        ShortStaticString{$N}($s, $n)
    end
end
_macroname(::Type{<:ShortStaticString}) = "Short"

"""
    Long"string"[N]

Create a [`LongStaticString`](@ref) from "string".
Optionally, specify the number of codeunits, `N`.

# Examples
```jldoctest
julia> Long"Як ти?"
Long"Як ти?"10

julia> Long"Як ти?"256
Long"Як ти?"256
```
"""
macro Long_str(ex)
    s = unescape_string(ex)
    quote
        LongStaticString($s)
    end
end
macro Long_str(ex, N)
    s = unescape_string(ex)
    n = ncodeunits(s)
    quote
        LongStaticString{$N}($s, $n)
    end
end
_macroname(::Type{<:LongStaticString}) = "Long"

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

julia> ccall(:printf, Cint, (Ptr{Cchar},), CStatic"Orada mısın\n"25)
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


