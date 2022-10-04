Base.codeunit(nstr::AbstractStaticString) = UInt8
Base.@propagate_inbounds Base.codeunit(s::AbstractStaticString, i::Int) = s.data[i]
@inline Base.ncodeunits(nstr::AbstractStaticString{N}) where N = N
Base.widen(nstr::AbstractStaticString) = String
Base.promote_rule(::Type{T}, ::Type{String}) where {T <: AbstractStaticString} = String


