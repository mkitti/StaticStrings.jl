function Base.read(io::IO, ::Type{T}) where {N, T <: AbstractStaticString{N}}
    convert(T, ntuple(N) do i
        read(io, UInt8)
    end)
end

function Base.read(io::IO, ::Type{CStaticString}; sizehint=255)
    buffer = UInt8[]
    sizehint!(buffer, sizehint)
    notnull = true
    while notnull
        byte = read(io, UInt8)
        notnull = byte != 0x00
        push!(buffer, byte)
    end
    return CStaticString((buffer...,))
end


@static if isdefined(Base, :AnnotatedIOBuffer)
    Base.write(io::Base.AnnotatedIOBuffer, string::AbstractStaticString) =
        @invoke write(io::IO, string::AbstractStaticString)
end

"""
    write_codeunits(io::IO, string::AbstractStaticString, count::Integer)

Write `count` bytes to `io` from the substring's starting index or index 1 otherwise.

Throw `BoundsError` if `count` is negative or any requested byte lies outside `data(string)`.
`@inbounds` skips these checks, making the caller responsible for preventing invalid memory reads.
"""
@inline function write_codeunits(io::IO, string::AbstractStaticString, count::Integer)
    count == 0 && return 0
    start = string isa SubStaticString ? first(string.ind) : 1
    @boundscheck 1 <= start <= length(data(string)) && 0 < count <= length(data(string)) - start + 1 ||
        throw(BoundsError(string, (start, count)))
    bytes = Ref(data(string))
    offset = Int(start) - 1
    GC.@preserve bytes begin
        pointer = Ptr{UInt8}(Base.unsafe_convert(Ptr{Cvoid}, bytes)) + offset
        return Int(unsafe_write(io, pointer, UInt(count)))
    end
end

function Base.write(io::IO, string::AbstractStaticString)
    count = string isa CStaticString ? length(data(string)) : ncodeunits(string)
    written = @inbounds write_codeunits(io, string, count)
    if string isa CStaticString && (count == 0 || data(string)[end] != 0x00)
        written += write(io, 0x00)
    end
    return written
end

Base.print(io::IO, string::AbstractStaticString) =
    (@inbounds write_codeunits(io, string, ncodeunits(string)); nothing)
