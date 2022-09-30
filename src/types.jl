"""
    AbstractStaticString{N}

Represents a string of `N` codeunits
"""
abstract type AbstractStaticString{N} <: AbstractString end

(ANS::Type{<:AbstractStaticString})(data::NTuple{N,Int8}) where N = ANS(UInt8.(data))
(ANS::Type{<:AbstractStaticString{N}})(data::NTuple{N,Int8}) where N = ANS(UInt8.(data))

"""
    StaticString(data::NTuple{N,UInt8})

[`AbstractStaticString`](@ref) that wraps a NTuple{N,UInt8}.
"""
struct StaticString{N} <: AbstractStaticString{N}
    data::NTuple{N,UInt8}
end
data(string::StaticString) = string.data

"""
    StaticCString(data::NTuple{N,UInt8})

[`AbstractStaticString`](@ref) that wraps a NTuple{N,UInt8} but requires NUL codeunits to be at the end.

N.B. The size of a `StaticCString{N}` is `N+1` bytes.
"""
struct CStaticString{N} <: AbstractStaticString{N}
    data::NTuple{N,UInt8}
    _nul::UInt8
    function CStaticString(data::NTuple{N,UInt8}) where N
        first_nul = findfirst(==(0x0), data)
        # isnothing(first_nul) && throw(ArgumentError("codeunit data does not contain a terminal null byte"))
        last_nonnul = findlast(!=(0x0), data)
        # Allow for multiple terminal null bytes at the end
        isnothing(first_nul) ||
        (last_nonnul < first_nul && 0x00 ∉  data[1:first_nul-1]) ||
            throw(ArgumentError("The data of a CStaticString must only contain terminal null bytes at the end."))
        return new{N}(data, 0x0)
    end
    function CStaticString{N}(data::NTuple{M,UInt8}) where {N,M}
        _data = ntuple(i->i <= M ? data[i] : 0x0, Val(N))
        return CStaticString(_data)
    end
end
data(string::CStaticString) = string.data
function Base.ncodeunits(string::CStaticString{N}) where N
    pos = findfirst(==(0x0), string.data)
    if isnothing(pos)
        return N
    else
        return pos-1
    end
end

"""
    PaddedStaticString{N,PAD}(data::NTuple{N,UInt8})

[`AbstractStaticString`](@ref) that is padded with `PAD`.
"""
struct PaddedStaticString{N,PAD} <: AbstractStaticString{N}
    data::NTuple{N,UInt8}
    function PaddedStaticString{N,PAD}(data::NTuple{M,UInt8}) where {N,M,PAD}
        isnothing(findfirst(==(PAD), data)) && ArgumentError("codeunit data contains PAD: '$PAD'")
        _data = ntuple(i->i <= M ? data[i] : UInt8(PAD), Val(N))
        return new{N,UInt8(PAD)}(_data)
    end
    PaddedStaticString{N}(data::NTuple{M,UInt8}) where {N,M} = PaddedStaticString{N,0x0}(data)
end
data(string::PaddedStaticString) = string.data
function Base.ncodeunits(string::PaddedStaticString{N,PAD}) where {N,PAD}
    pos = findfirst(==(UInt8(PAD)), string.data)
    if isnothing(pos)
        return N
    else
        return pos - 1
    end
end
