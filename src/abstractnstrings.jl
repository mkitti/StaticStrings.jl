Base.codeunit(nstr::AbstractNString) = UInt8
Base.@propagate_inbounds Base.codeunit(nstr::AbstractNString, i::Int) = nstr.data[i]
@inline Base.ncodeunits(nstr::AbstractNString{N}) where N = N
Base.widen(nstr::AbstractNString) = String
Base.promote_rule(::Type{T}, ::Type{String}) where {T <: AbstractNString} = String


