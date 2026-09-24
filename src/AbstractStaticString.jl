"""
    AbstractStaticString{N}

Represent a string with backing capacity for `N` UTF-8 code units.

`ncodeunits(string)` counts logical bytes, which can be fewer than `N`.
`Tuple(string)` exposes all `N` backing bytes.
"""
abstract type AbstractStaticString{N} <: AbstractString end

(ASS::Type{<:AbstractStaticString})(data::NTuple{N,Int8}) where N = ASS{N}(UInt8.(data))
(ASS::Type{<:AbstractStaticString{N}})(data::NTuple{N,Int8}) where N = ASS(UInt8.(data))

Base.@deprecate data(s::AbstractStaticString) Tuple(s) false

Base.codeunit(::AbstractStaticString) = UInt8
Base.@propagate_inbounds Base.codeunit(s::AbstractStaticString, i::Int) = codeunits(s)[i]
@inline Base.codeunits(s::AbstractStaticString) = data(s)
@inline Base.ncodeunits(::AbstractStaticString{N}) where N = N
@inline Base.ncodeunits(::Type{<: AbstractStaticString{N}}) where N = N
Base.widen(::Type{<: AbstractStaticString}) = String
Base.widen(s::AbstractStaticString) = String(s)
Base.promote_rule(::Type{T}, ::Type{String}) where {T <: AbstractStaticString} = String


