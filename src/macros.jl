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

