"""
    AbstractNString{N}

Represents a string of N codeunits
"""
abstract type AbstractNString{N} <: AbstractString end

(ANS::Type{<:AbstractNString})(data::NTuple{N,Int8}) where N = ANS(UInt8.(data))

"""
    NString(data::NTuple{N,UInt8})

[`AbstractNString`](@ref) that wraps a NTuple{N,UInt8}.
"""
struct NString{N} <: AbstractNString{N}
    data::NTuple{N,UInt8}
end
data(nstring::NString) = nstring.data
ndata(nstring::NString) = nstring.data

"""
    CNString(data::NTuple{N,UInt8})

[`AbstractNString`](@ref) that wraps a NTuple{N,UInt8}.
"""
struct CNString{N} <: AbstractNString{N}
    data::NTuple{N,UInt8}
    function CNString(data::NTuple{N,UInt8}) where N
        findfirst(==(0x0), data) == N ||
            throw(ArgumentError("The data of a CNString must only contain a
                                terminal null byte at the end."))
        return new{N}(data)
    end
end
data(nstring::CNString) = nstring.data
ndata(nstring::CNString) = nstring.data
