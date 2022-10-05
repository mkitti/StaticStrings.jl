Base.codeunit(::AbstractStaticString) = UInt8
Base.@propagate_inbounds Base.codeunit(s::AbstractStaticString, i::Int) = codeunits(s)[i]
@inline Base.codeunits(s::AbstractStaticString) = s.data
@inline Base.ncodeunits(::AbstractStaticString{N}) where N = N
Base.widen(::AbstractStaticString) = String
Base.promote_rule(::Type{T}, ::Type{String}) where {T <: AbstractStaticString} = String


