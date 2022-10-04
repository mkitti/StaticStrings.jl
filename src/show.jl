function Base.show(io::IO, ::MIME"text/plain", s::AbstractStaticString{N}) where N
    print(io, "$(_macroname(typeof(s)))\"")
    print(io, s)
    print(io, "\"$N")
end
function Base.show(io::IO, ::MIME"text/plain", s::PaddedStaticString{N,PAD}) where {N, PAD}
    print(io, "$(_macroname(typeof(s)))\"")
    print(io, s)
    print(io, Char(PAD))
    print(io, "\"$N")
end
