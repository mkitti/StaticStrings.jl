"""
    AbstractStaticString{N}

Represents a string of `N` codeunits
"""
abstract type AbstractStaticString{N} <: AbstractString end

(ASS::Type{<:AbstractStaticString})(data::NTuple{N,Int8}) where N = ASS(UInt8.(data))
(ASS::Type{<:AbstractStaticString{N}})(data::NTuple{N,Int8}) where N = ASS(UInt8.(data))

"""
    StaticString(data::NTuple{N,UInt8})

[`AbstractStaticString`](@ref) that stores codeunits in a NTuple{N,UInt8}.
"""
struct StaticString{N} <: AbstractStaticString{N}
    data::NTuple{N,UInt8}
end
data(string::StaticString) = string.data

"""
    ShortStaticString(data::NTuple{N,UInt8}, ncodeunits::UInt8)

[`AbstractStaticString`](@ref) that stores ncodeunits codeunits in a NTuple{N,UInt8} 

N.B. The size of a `ShortStaticString{N}` is `N+1` bytes.
"""
struct ShortStaticString{N} <: AbstractStaticString{N}
    data::NTuple{N,UInt8}
    ncodeunits::UInt8
end
ShortStaticString{N}(data::NTuple{N,UInt8}) where N = ShortStaticString{N}(data, N)
ShortStaticString(data::NTuple{N,UInt8}) where N = ShortStaticString{N}(data, N)
@inline Base.ncodeunits(s::ShortStaticString)::Int = s.ncodeunits
data(string::ShortStaticString) = string.data

"""
    LongStaticString(data::NTuple{N,UInt8}, ncodeunits::Int)

[`AbstractStaticString`](@ref) that stores ncodeunits codeunits in a NTuple{N,UInt8} 

N.B. The size of a `LongStaticString{N}` is `N+8` bytes.
"""
struct LongStaticString{N} <: AbstractStaticString{N}
    data::NTuple{N,UInt8}
    ncodeunits::Int
end
LongStaticString{N}(data::NTuple{N,UInt8}) where N = LongStaticString{N}(data, N)
LongStaticString(data::NTuple{N,UInt8}) where N = LongStaticString{N}(data, N)
@inline Base.ncodeunits(s::LongStaticString)::Int = s.ncodeunits
data(string::LongStaticString) = string.data

"""
    CStaticString(data::NTuple{N,UInt8})

[`AbstractStaticString`](@ref) that stores codeunits in a NTuple{N,UInt8} but requires NUL codeunits to be at the end.

N.B. The size of a `CStaticString{N}` is `N+1` bytes.
"""
struct CStaticString{N} <: AbstractStaticString{N}
    data::NTuple{N,UInt8}
    _nul::UInt8
    function CStaticString(data::NTuple{N,UInt8}) where N
        _check_for_nuls(data)
        return new{N}(data, 0x0)
    end
    function CStaticString{N}(data::NTuple{M,UInt8}) where {N,M}
        _data = ntuple(i->i <= M ? data[i] : 0x0, Val(N))
        return CStaticString(_data)
    end
end
function _check_for_nuls(data::NTuple{N,UInt8}) where N
    first_nul = 0
    last_nonnul = 0
    for i in eachindex(data)
        if data[i] == 0x0
            if first_nul == 0
                first_nul = i
            end
        else
            last_nonnul = i
        end
    end
    # Allow for no nul byte since we have a safety nul byte
    last_nonnul <= first_nul || first_nul == 0 ||
        throw(ArgumentError("The data of a CStaticString must only contain terminal null bytes at the end."))
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
        _data = ntuple(i->i <= M ? data[i] : UInt8(PAD), Val(N))
        return new{N,UInt8(PAD)}(_data)
    end
    function PaddedStaticString{N,PAD}(s::AbstractString) where {N,PAD}
        data = codeunits(s)
        M = ncodeunits(s)
        _data = ntuple(i->i <= M ? data[i] : UInt8(PAD), Val(N))
        return new{N,UInt8(PAD)}(_data)
    end
    PaddedStaticString{N}(data::AbstractString) where N = PaddedStaticString{N,0x0}(data)
    PaddedStaticString{N}(data::NTuple{M,UInt8} where M) where N = PaddedStaticString{N,0x0}(data)
end

data(string::PaddedStaticString) = string.data
pad(string::PaddedStaticString{N,PAD} where N) where PAD = PAD

function Base.ncodeunits(string::PaddedStaticString{N,PAD}) where {N,PAD}
    pos = findlast(!=(UInt8(PAD)), string.data)
    if isnothing(pos)
        return 0
    else
        return pos
    end
end
