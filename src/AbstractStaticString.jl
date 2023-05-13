"""
    AbstractStaticString{N}

Represents a string of `N` codeunits
"""
abstract type AbstractStaticString{N} <: AbstractString end

(ASS::Type{<:AbstractStaticString})(data::NTuple{N,Int8}) where N = ASS{N}(UInt8.(data))
(ASS::Type{<:AbstractStaticString{N}})(data::NTuple{N,Int8}) where N = ASS(UInt8.(data))

"""
    StaticStrings.data(string::AbstractStaticString{N})::NTuple{N,UInt8} where N

Retrieve the internal `Tuple` containing the `N` stored `UInt8` code units.
"""
data(s::AbstractStaticString) = s.data

Base.codeunit(::AbstractStaticString) = UInt8
Base.@propagate_inbounds Base.codeunit(s::AbstractStaticString, i::Int) = codeunits(s)[i]
@inline Base.codeunits(s::AbstractStaticString) = data(s)
@inline Base.ncodeunits(::AbstractStaticString{N}) where N = N
Base.widen(::AbstractStaticString) = String
Base.promote_rule(::Type{T}, ::Type{String}) where {T <: AbstractStaticString} = String


