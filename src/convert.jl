# Convert between AbstractStaticStrings

SubStaticString(s::AbstractString) = SubStaticString{ncodeunits(s)}(s)
SubStaticString{N}(s::AbstractString) where N = SubStaticString{N, Base.OneTo{Int}}(s)
SubStaticString{N,R}(s::AbstractString) where {N, R <: AbstractUnitRange{<:Integer}} =
    SubStaticString{N,R}(s, R(Base.OneTo(Int(ncodeunits(s)))))
SubStaticString(s::AbstractString, ind::AbstractUnitRange{<:Integer}) =
    SubStaticString{ncodeunits(s)}(s, ind)
SubStaticString{N}(s::AbstractString, ind::R) where {N, R <: AbstractUnitRange{<:Integer}} =
    SubStaticString{N,R}(s, ind)
SubStaticString(s::AbstractString, count::Integer) = SubStaticString(s, Base.OneTo(count))
SubStaticString{N}(s::AbstractString, count::Integer) where N = SubStaticString{N}(s, Base.OneTo(count))

# Convert AbstractStaticString to String

# Thank you to Steven G. Johnson @stevengj
# https://discourse.julialang.org/t/convert-a-ntuple-n-uint8-to-a-string-and-back/87720/2?u=mkitti
function Base.String(string::AbstractStaticString{N}) where N
    count = ncodeunits(string)
    count == 0 && return ""
    bytes = Ref(Tuple(string))
    offset = string isa SubStaticString ? Int(first(string.ind)) - 1 : 0
    # The string invariants guarantee `0 <= offset < offset + count <= N`.
    GC.@preserve bytes begin
        pointer = Ptr{UInt8}(Base.unsafe_convert(Ptr{Cvoid}, bytes)) + offset
        return unsafe_string(pointer, count)
    end
end

# Convert [Abstract]String to AbstractStaticStrings

function StaticString(s::AbstractString)
    codeunit(s) == UInt8 ||
        throw(ArgumentError("Only AbstractStrings with UInt8 codeunits can be converted to StaticString"))
    return StaticString(NTuple{ncodeunits(s),UInt8}(codeunits(s)))
end
@inline function StaticString{N}(s::AbstractString) where N
    nc = ncodeunits(s)
    codeunit(s) == UInt8 ||
        throw(ArgumentError("Only AbstractStrings with UInt8 codeunits can be converted to StaticString"))
    nc <= N || throw(InexactError(:StaticString, StaticString{N}, s))
    StaticString{N}(ntuple(i -> i <= nc ? (@inbounds codeunit(s, i)) : 0x00, Val(N)))
end
(ass::Type{ASS})(s::AbstractString, args...) where {ASS <: AbstractStaticString} = ass(Tuple(StaticString(s)), args...)
(ass::Type{ASS})(s::AbstractString, args...) where {N, ASS <: AbstractStaticString{N}} = ass(Tuple(StaticString{N}(s)), args...)

## [Abstract]String to PaddedStaticString

"""
    StaticStrings.pad(s::AbstractString, N::Integer, PAD::UInt8=0x0)::PaddedStaticString

Pad an `AbstractString` to `N` code units with the code unit `PAD`.
"""
pad(s::AbstractString, N::Integer, PAD::UInt8=0x0) =
    PaddedStaticString{N,PAD}(s)

# Tuple
"""
    Tuple(string::AbstractStaticString{N})::NTuple{N, UInt8} where N

Retrieve the internal `Tuple` containing all `N` backing bytes, including bytes outside the logical content.
"""
Base.Tuple(nstring::AbstractStaticString) = nstring.data
Base.convert(::Type{Tuple}, nstring::AbstractStaticString) = Tuple(nstring)
Base.convert(::Type{T}, nstring::AbstractStaticString) where {T <: NTuple{N, UInt8} where N} = Tuple(nstring)
Base.convert(::Type{NTuple{N, UInt8}}, nstring::AbstractStaticString{N}) where N = Tuple(nstring)

Base.convert(::Type{T}, t::NTuple{N, UInt8}) where {N, T <: AbstractStaticString{N}} = T(t)

# Unsafe conversions

function Base.cconvert(::Type{Ptr{UInt8}}, nstring::NS) where NS <: AbstractStaticString
    convert(Ref{NS}, nstring)
end

function Base.cconvert(::Type{Ptr{Int8}}, nstring::NS) where NS <: AbstractStaticString
    convert(Ref{NS}, nstring)
end

function Base.unsafe_convert(::Type{Ptr{UInt8}}, ref_s::Base.RefValue{<: AbstractStaticString})
    return Ptr{UInt8}(pointer_from_objref(ref_s))
end

function Base.unsafe_convert(::Type{Ptr{UInt8}}, ref_s::Base.RefValue{<:SubStaticString})
    string = ref_s[]
    offset = isempty(string.ind) ? 0 : Int(first(string.ind)) - 1
    return Ptr{UInt8}(pointer_from_objref(ref_s)) + offset
end

function Base.unsafe_convert(::Type{Ptr{Int8}}, ref_s::Base.RefValue{<: AbstractStaticString})
    return Ptr{Int8}(Base.unsafe_convert(Ptr{UInt8}, ref_s))
end

function Base.cconvert(::Type{Cstring}, nstring::AbstractStaticString)
    return String(nstring)
end

# SubString and SubStaticString
Base.convert(::Type{SubString{StaticString{N}}}, sss::SubStaticString{N}) where {N} = SubString{StaticString{N}}(StaticString{N}(sss.data), sss.ind)
Base.convert(::Type{SubString}, sss::SubStaticString{N}) where {N} = SubString(StaticString{N}(sss.data), sss.ind)
Base.convert(::Type{T}, substr::SubString{ASS}) where {T <: SubStaticString, ASS <: AbstractStaticString} =
    T(substr.string, substr.offset+1:substr.offset+substr.ncodeunits)
