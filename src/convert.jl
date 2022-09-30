# Convert between AbstractStaticStrings

function StaticString(s::AbstractStaticString{N}) where N
    return StaticString{N}(data(s))
end
Base.convert(::Type{StaticString{N}}, s::AbstractStaticString{N}) where N = StaticString(s)

function CStaticString(s::AbstractStaticString{N}) where N
    #=
    _data = data(s)
    M = findfirst(==(0x0), _data)
    if isnothing(M)
        error("A CStaticString must have a terminal NUL byte")
    else
        CStaticString(_data[1:M])
    end
    =#
    CStaticString(data(s))
end
CStaticString{N}(s::AbstractStaticString{N}) where N = CStaticString(data(s))
PaddedStaticString{N, PAD}(s::AbstractStaticString) where {N,PAD} = PaddedStaticString{N, PAD}(data(s))
PaddedStaticString{N}(s::AbstractStaticString) where N = PaddedStaticString{N}(data(s))

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

# Convert String to AbstractStaticStrings

function StaticString(s::AbstractString)
    codeunit(s) == UInt8 ||
        throw(ArgumentError("Only AbstractStrings with UInt8 codeunits can be converted to StaticString"))
    return StaticString(NTuple{ncodeunits(s),UInt8}(s))
end
function StaticString{N}(s::AbstractString) where N 
    nc = ncodeunits(s)
    StaticString{N}(ntuple(i->i <= nc ? codeunit(s,i) : 0x00, N))
end
CStaticString(s::AbstractString) = CStaticString(StaticString(s))
CStaticString{N}(s::AbstractString) where N = CStaticString{N}(StaticString{N}(s))
PaddedStaticString{N, PAD}(s::AbstractString) where {N,PAD} = PaddedStaticString{N, PAD}(StaticString(s))
PaddedStaticString{N}(s::AbstractString) where {N} = PaddedStaticString{N}(StaticString(s))

# Tuple
Base.Tuple(nstring::AbstractStaticString) = data(nstring)
Base.convert(::Type{Tuple}, nstring::AbstractStaticString) = Tuple(nstring)
Base.convert(::Type{T}, nstring::AbstractStaticString) where {T <: NTuple{N,UInt8} where N} = data(nstring)

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
