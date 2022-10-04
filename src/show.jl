function Base.show(io::IO, ::MIME"text/plain", s::AbstractStaticString{N}) where N
    print(io, "$(_macroname(typeof(s)))")
    Base.print_quoted(io, s)
    print(io, "$N")
end
function Base.show(io::IO, ::MIME"text/plain", s::PaddedStaticString{N,PAD}) where {N, PAD}
    print(io, "$(_macroname(typeof(s)))\"")
    #print(io, s)
    # From Julia Base.print_quoted
    escape_string(io, s, ('\"','$')) #"# work around syntax highlighting problem
    print(io, Char(PAD))
    print(io, "\"$N")
end
