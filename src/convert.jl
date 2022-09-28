# Convert between AbstractNStrings


function NString(s::AbstractNString{N}) where N
    return NString{N}(ndata(s))
end
Base.convert(::Type{NString{N}}, s::AbstractNString{N}) where N = NString(s)

function CNString(s::AbstractNString{N}) where N
    _data = data(s)
    M = findfirst(==(0x0), _data)
    if isnothing(M)
        error("A CNString must have a terminal NUL byte")
    else
        CNString(_data[1:M])
    end
end

# Convert AbstractNString to String

# Thank you to Steven G. Johnson @stevengj
# https://discourse.julialang.org/t/convert-a-ntuple-n-uint8-to-a-string-and-back/87720/2?u=mkitti
function Base.String(nstring::AbstractNString{N}) where {N}
    b = Base.StringVector(N)
    return String(b .= ndata(nstring))
end
function Base.convert(::Type{String}, nstring::AbstractNString{N}) where N
    return String(nstring)
end

# Convert String to AbstractNStrings

function NString(s::AbstractString)
    return NString(ntuple(i->codeunit(s,i), ncodeunits(s)))
end
CNString(s::AbstractString) = CNString(NString(s))

# Tuple
Base.Tuple(nstring::AbstractNString) = data(nstring)
Base.convert(::Type{Tuple}, nstring::AbstractNString) = Tuple(nstring)
Base.convert(::Type{T}, nstring::AbstractNString) where {T <: NTuple{N,UInt8} where N} = data(nstring)

# Unsafe conversions

function Base.cconvert(::Type{Ptr{UInt8}}, nstring::NS) where NS <: AbstractNString
    convert(Ref{NS}, nstring)
end

function Base.cconvert(::Type{Ptr{Int8}}, nstring::NS) where NS <: AbstractNString
    convert(Ref{NS}, nstring)
end

function Base.unsafe_convert(::Type{Ptr{UInt8}}, ref_s::Ref{<: AbstractNString})
    return Ptr{UInt8}(pointer_from_objref(ref_s))
end

function Base.unsafe_convert(::Type{Ptr{Int8}}, ref_s::Ref{<: AbstractNString})
    return Ptr{Int8}(pointer_from_objref(ref_s))
end

function Base.cconvert(::Type{Cstring}, nstring::AbstractNString)
    return String(nstring)
end
