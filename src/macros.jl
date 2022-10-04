"""
    Static"string"N

Create a [`StaticString`](@ref) from "string".
Optionally, specify the number of codeunits, `N`.
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
    Short"string"N

Create a [`ShortStaticString`](@ref) from "string".
Optionally, specify the number of codeunits, `N`.
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
    Long"string"N

Create a [`LongStaticString`](@ref) from "string".
Optionally, specify the number of codeunits, `N`.
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

Create a [`CstaticString`](@ref) from "string".
Optionally, specify the number of codeunits, `N`.
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

Creat [`PaddedStaticString`](@ref) of `N` codeunits from "string".
The last codeunit in the provided string becomes the pad.
"""
macro Padded_str(ex, N)
    s = unescape_string(ex)
    pad = codeunits(s)[end]
    quote
        PaddedStaticString{$N, $pad}($s)
    end
end
_macroname(::Type{<:PaddedStaticString}) = "Padded"


