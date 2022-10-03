"""
    Static"string"N

Create a [`StaticString`](@ref) from "string".
Optionally specify the number of codeunits, `N`.
"""
macro Static_str(ex)
    s = unescape_string(ex)
    quote
        StaticString(unescape_string($s))
    end
end
macro Static_str(ex, N)
    s = unescape_string(ex)
    quote
        StaticString{$N}($s)
    end
end

"""
    CStatic"string"[N]

Create a [`CstaticString`](@ref) from "string".
Optionally specify the number of codeunits, `N`.
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

