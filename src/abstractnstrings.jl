Base.codeunit(nstr::AbstractStaticString) = UInt8
Base.@propagate_inbounds Base.codeunit(nstr::AbstractStaticString, i::Int) = nstr.data[i]
@inline Base.ncodeunits(nstr::AbstractStaticString{N}) where N = N
Base.widen(nstr::AbstractStaticString) = String
Base.promote_rule(::Type{T}, ::Type{String}) where {T <: AbstractStaticString} = String


