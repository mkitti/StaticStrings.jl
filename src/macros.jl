macro N_str(ex)
    quote
        NString(unescape_string($ex))
    end
end

macro CN_str(ex)
    quote
        CNString(unescape_string($ex))
    end
end
