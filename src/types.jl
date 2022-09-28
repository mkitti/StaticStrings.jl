"""
    AbstractStaticString{N}

Represents a string of `N` codeunits
"""
abstract type AbstractStaticString{N} <: AbstractString end

(ANS::Type{<:AbstractStaticString})(data::NTuple{N,Int8}) where N = ANS(UInt8.(data))

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
        last_nonnul = findlast(!=(0x0), data)
        # Allow for multiple terminal null bytes at the end
        isnothing(first_nul) || # Therea are no nuls
        (last_nonnul < first_nul && 0x00 ∉  data[1:first_nul-1]) ||
            throw(ArgumentError("The data of a CStaticString must only contain terminal null bytes at the end."))
        return new{N}(data, 0x00)
    end
end
data(string::CStaticString) = string.data
