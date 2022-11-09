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
function Base.write(io::IO, ass::T) where {N, T<: AbstractStaticString{N}}
    foreach(codeunits(ass)) do byte
        write(io, byte)
    end
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
