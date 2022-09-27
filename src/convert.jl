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

function NMString(s::AbstractNString{N}) where N
    return NMString(data(s), N)
end
Base.convert(::Type{NMString{N}}, s::AbstractNString{N}) where N = NMString(s)

function CNMString(s::AbstractNString{N}) where N
    _data = data(s)
    if length(_data) > N && _data[N+1] == 0x0
        return CNMString{N}(_data)
    else
        _data = (_data..., 0x0)
        return CNMString{N}(_data)
    end
end
Base.convert(::Type{CNMString{N}}, s::AbstractNString{N}) where N = CNMString(s)

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
function NMString(s::AbstractString)
    N = M = ncodeunits(s)
    return NMString(ntuple(i->codeunit(s,i), N), N)
end
function CNMString(s::AbstractString)
    N = ncodeunits(s)
    Base.containsnul(s) && throw(ArgumentError("Argument must not contain internal NULs"))
    return CNMString(ntuple(i->codeunit(s,i), N))
end

# Tuple
Base.Tuple(nstring::AbstractNString) = data(nstring)
Base.convert(::Type{Tuple}, nstring::AbstractNString) = Tuple(nstring)
Base.convert(::Type{T}, nstring::AbstractNString) where {T <: NTuple{N,UInt8} where N} = data(nstring)

# Unsafe conversions

function Base.unsafe_convert(::Type{Ptr{UInt8}}, ref_s::Ref{NMString{N}}) where N
    return Ptr{UInt8}(pointer(s))
end

function Base.unsafe_convert(::Type{Ptr{Int8}}, ref_s::Ref{NMString{N}}) where N
    return Ptr{Int8}(pointer(s))
end

function Base.unsafe_convert(::Type{Cstring}, ref_s::Ref{NMString{N}}) where N
    data(ref_s[])[N+1] == 0x0 || throw(ArgumentError("The NMString is not null terminated"))
    return Cstring(Base.unsafe_convert(Ptr{UInt8}, ref_s))
end

function Base.cconvert(::Type{Cstring}, nstring::AbstractNString)
    return String(nstring)
end

function Base.unsafe_convert(::Type{Cstring}, ref_s::Ref{CNMString})
    Cstring(Ptr{UInt8}(pointer_from_objref(ref_s)))
end
