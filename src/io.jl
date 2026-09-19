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
    Base.write(io::Base.AnnotatedIOBuffer, cs::CStaticString{N}) where N =
        invoke(write, Tuple{IO, CStaticString{N}}, io, cs)
    Base.write(io::Base.AnnotatedIOBuffer, string::SubStaticString) =
        invoke(write, Tuple{IO, SubStaticString}, io, string)
end

function Base.write(io::IO, string::SubStaticString)
    written = 0
    for index in 1:ncodeunits(string)
        written += write(io, @inbounds codeunit(string, index))
    end
    return written
end

function Base.write(io::IO, cs::CStaticString{N}) where N
    foreach(codeunits(cs)) do byte
        write(io, byte)
    end
    if data(cs)[end] != 0x00
        write(io, 0x00)
        return N + 1
    else
        return N
    end
end

Base.print(io::IO, string::SubStaticString) = (write(io, string); nothing)
