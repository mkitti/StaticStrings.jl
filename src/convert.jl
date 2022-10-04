# Convert between AbstractStaticStrings

StaticString(s::AbstractStaticString{N}) where N = StaticString{N}(data(s))
StaticString{N}(s::AbstractStaticString{N}) where N = StaticString{N}(data(s))
Base.convert(::Type{StaticString{N}}, s::AbstractStaticString{N}) where N = StaticString(s)

(ass::Type{ASS})(s::AbstractStaticString) where {ASS <: AbstractStaticString} = ass(data(s))
(ass::Type{ASS})(s::AbstractStaticString{N}) where {N, ASS <: AbstractStaticString{N}} = ass(data(s))
ShortStaticString(s::AbstractStaticString, ncodeunits) = ShortStaticString(data(s), ncodeunits)
ShortStaticString{N}(s::AbstractStaticString, ncodeunits) where N = ShortStaticString{N}(data(s), ncodeunits)
LongStaticString(s::AbstractStaticString, ncodeunits) = LongStaticString(data(s), ncodeunits)
LongStaticString{N}(s::AbstractStaticString, ncodeunits) where N = LongStaticString{N}(data(s), ncodeunits)
PaddedStaticString{N}(s::AbstractStaticString) where N = PaddedStaticString{N}(data(s))
PaddedStaticString{N}(s::AbstractStaticString{N}) where N = PaddedStaticString{N}(data(s))

# Convert AbstractStaticString to String

# Thank you to Steven G. Johnson @stevengj
# https://discourse.julialang.org/t/convert-a-ntuple-n-uint8-to-a-string-and-back/87720/2?u=mkitti
function Base.String(nstring::AbstractStaticString{N}) where {N}
    b = Base.StringVector(N)
    return String(b .= data(nstring))
end
function Base.convert(::Type{String}, nstring::AbstractStaticString{N}) where N
    return String(nstring)
end

# Convert [Abstract]String to AbstractStaticStrings

function StaticString(s::AbstractString)
    codeunit(s) == UInt8 ||
        throw(ArgumentError("Only AbstractStrings with UInt8 codeunits can be converted to StaticString"))
    return StaticString(NTuple{ncodeunits(s),UInt8}(s))
end
function StaticString{N}(s::AbstractString) where N 
    nc = ncodeunits(s)
    codeunit(s) == UInt8 ||
        throw(ArgumentError("Only AbstractStrings with UInt8 codeunits can be converted to StaticString"))
    nc <= N || throw(InexactError("\"$s\" contains more than $N codeunits."))
    StaticString{N}(ntuple(i->i <= nc ? codeunit(s,i) : 0x00, Val(N)))
end
(ass::Type{ASS})(s::AbstractString) where {ASS <: AbstractStaticString} = ass(StaticString(s))
(ass::Type{ASS})(s::AbstractString) where {N, ASS <: AbstractStaticString{N}} = ass(StaticString{N}(s))
ShortStaticString(s::AbstractString, ncodeunits) = ShortStaticString(StaticString(s), ncodeunits)
ShortStaticString{N}(s::AbstractString, ncodeunits) where N = ShortStaticString{N}(StaticString{N}(s), ncodeunits)
LongStaticString(s::AbstractString, ncodeunits) = LongStaticString(StaticString(s), ncodeunits)
LongStaticString{N}(s::AbstractString, ncodeunits) where N = LongStaticString{N}(StaticString{N}(s), ncodeunits)

## [Abstract]String to PaddedStaticString

pad(s::AbstractString, N::Integer, PAD::UInt8=0x0) =
    PaddedStaticString{N,PAD}(s)

# Tuple
Base.Tuple(nstring::AbstractStaticString) = data(nstring)
Base.convert(::Type{Tuple}, nstring::AbstractStaticString) = Tuple(nstring)
Base.convert(::Type{T}, nstring::AbstractStaticString) where {T <: NTuple{N,UInt8} where N} = data(nstring)
Base.convert(::Type{NTuple{N,UInt8}}, nstring::AbstractStaticString{N}) where N = data(nstring)

# Unsafe conversions

function Base.cconvert(::Type{Ptr{UInt8}}, nstring::NS) where NS <: AbstractStaticString
    convert(Ref{NS}, nstring)
end

function Base.cconvert(::Type{Ptr{Int8}}, nstring::NS) where NS <: AbstractStaticString
    convert(Ref{NS}, nstring)
end

function Base.unsafe_convert(::Type{Ptr{UInt8}}, ref_s::Ref{<: AbstractStaticString})
    return Ptr{UInt8}(pointer_from_objref(ref_s))
end

function Base.unsafe_convert(::Type{Ptr{Int8}}, ref_s::Ref{<: AbstractStaticString})
    return Ptr{Int8}(pointer_from_objref(ref_s))
end

function Base.cconvert(::Type{Cstring}, nstring::AbstractStaticString)
    return String(nstring)
end
