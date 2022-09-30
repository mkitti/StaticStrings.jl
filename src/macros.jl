"""
    Static"string"N

Create a [`StaticString`](@ref) from "string".
Optionally specify the number of codeunits, `N`.
"""
macro Static_str(ex)
    quote
        StaticString(unescape_string($ex))
    end
end
macro Static_str(ex, N)
    quote
        StaticString{$N}(unescape_string($ex))
    end
end

"""
    CStatic"string"[N]

Create a [`CstaticString`](@ref) from "string".
Optionally specify the number of codeunits, `N`.
"""
macro CStatic_str(ex)
    quote
        CStaticString(unescape_string($ex))
    end
end
macro CStatic_str(ex, N)
    quote
        CStaticString{$N}(unescape_string($ex))
    end
end

"""
    Padded"string[PAD]"N

Creat [`PaddedStaticString`](@ref) of `N` codeunits from "string".
The last codeunit in the provided string becomes the pad.
"""
macro Padded_str(ex, N)
    quote
        let escaped = unescape_string($ex)
            PaddedStaticString{$N, codeunits(escaped)[end]}(escaped)
        end
    end
end

