
"""
    StaticString(data::NTuple{N,UInt8})
    static"string"N

Store exactly `N` logical bytes in an `NTuple{N, UInt8}`.

Every byte is content, including NUL bytes added by `StaticString{N}(string)`.
"""
struct StaticString{N} <: AbstractStaticString{N}
    data::NTuple{N,UInt8}
    StaticString{0}(data::Tuple{}=()) = new{0}(data)
    StaticString{N}(data::NTuple{N,UInt8}) where N = new{N}(data)
    StaticString(data::NTuple{N,UInt8}) where N = new{N}(data)
    StaticString(data::Tuple{}) = new{0}(data)
end

"""
    SubStaticString(data::NTuple{N, UInt8}, ind::Integer)
    SubStaticString(data::NTuple{N, UInt8}, ind::AbstractUnitRange{<:Integer})
    SubStaticString(string::AbstractString)
    SubStaticString{N}(string::AbstractString)
    substatic"string"N

Store up to `N` logical bytes selected by an integer unit range.

All selected bytes, including NULs, are content. `SubStaticString(string)`
infers `N = ncodeunits(string)`. `SubStaticString{N}(string)`
uses `Base.OneTo{Int}(ncodeunits(string))` and pads only the backing storage.
Explicit ranges select logical source bytes for string inputs and backing bytes
for tuple inputs. Inputs longer than `N` bytes are rejected.
"""
struct SubStaticString{N, R <: AbstractUnitRange{<:Integer}} <: AbstractStaticString{N}
    data::NTuple{N, UInt8}
    ind::R
    function SubStaticString{N,R}(data, ind::R) where {N, R <: AbstractUnitRange{<:Integer}}
        ind ⊆ eachindex(data) || throw_invalid_range(ind, eachindex(data))
        return new{N, R}(data, ind)
    end
    function SubStaticString{N,R}(string::AbstractString, ind::R) where {N, R <: AbstractUnitRange{<:Integer}}
        ind ⊆ Base.OneTo(ncodeunits(string)) || throw_invalid_range(ind, Base.OneTo(ncodeunits(string)))
        return SubStaticString{N, R}(Tuple(StaticString{N}(string)), ind)
    end
    SubStaticString(data::NTuple{N, UInt8}, ind::R) where {N, R <: AbstractUnitRange{<:Integer}} = SubStaticString{N,R}(data, ind)
end

# Keep error-message allocation and GC frame setup off the valid constructor path.
@noinline throw_invalid_range(ind::AbstractUnitRange, indices::AbstractUnitRange) =
    throw(ArgumentError("$ind is not a subset of $indices, the indices of data"))

SubStaticString{N}(data::NTuple{N, UInt8}, ind::R) where {N, R <: AbstractUnitRange{<:Integer}} = SubStaticString{N, R}(data, ind)
SubStaticString(data::NTuple{N, UInt8}, ind::Integer=length(data)) where N = SubStaticString(data, Base.OneTo(ind))
SubStaticString(data::Tuple{}=(), ind::Integer=length(data)) = SubStaticString(data, Base.OneTo(ind))
SubStaticString{N}(data::NTuple{N, UInt8}, ind::Integer=length(data)) where N = SubStaticString{N}(data, Base.OneTo(ind))
SubStaticString{0}(data::Tuple{}=(), ind::Integer=length(data)) = SubStaticString{0}(data, Base.OneTo(ind))
@inline Base.ncodeunits(s::SubStaticString) = Int(length(s.ind))

"""
    codeunits(text::SubStaticString)

Return a tuple of the active bytes in `text`.

When the active length varies at runtime, constructing and iterating that tuple
can allocate. Use `Base.CodeUnits(text)` to iterate over the active bytes through
`codeunit` without constructing a tuple slice.
"""
@inline Base.codeunits(s::SubStaticString) = s.data[s.ind]

# Base forwards other Integer indices to Int, matching the AbstractStaticString method.
Base.@propagate_inbounds function Base.codeunit(s::SubStaticString, index::Int)
    @boundscheck 1 <= index <= ncodeunits(s) || throw_bounds_error(s, index)
    return @inbounds s.data[Int(first(s.ind)) + index - 1]
end

@noinline throw_bounds_error(s, index) = throw(BoundsError(s, index))

"""
    CStaticString(data::NTuple{N,UInt8})
    cstatic"string"N

Store up to `N` logical bytes with guaranteed C-compatible NUL termination.

Logical content consists of the backing bytes preceding the first NUL.
If none of the `N` backing bytes is NUL, all `N` bytes are content.
`String`, `codeunits`, `print`, and `write` exclude the terminator and all subsequent bytes.

An additional safety NUL makes the object occupy `N+1` bytes.
"""
struct CStaticString{N} <: AbstractStaticString{N}
    data::NTuple{N,UInt8}
    _nul::UInt8
    function CStaticString(data::NTuple{N,UInt8}) where N
        return new{N}(data, 0x0)
    end
    function CStaticString{N}(data::NTuple{M,UInt8}) where {N,M}
        M <= N || throw(InexactError(:CStaticString, CStaticString{N}, data))
        _data = ntuple(i->i <= M ? data[i] : 0x0, Val(N))
        return CStaticString(_data)
    end
    CStaticString{N}(::Tuple{}=()) where {N} = new{N}(ntuple(i->0x0, Val(N)), 0x0)
    CStaticString{0}(::Tuple{}=()) = new{0}((), 0x0)
    CStaticString(::Tuple{}=()) = new{0}((), 0x0)
end
function Base.ncodeunits(string::CStaticString{N}) where N
    pos = findfirst(==(0x0), string.data)
    if isnothing(pos)
        return N
    else
        return pos-1
    end
end

Base.codeunits(string::CStaticString) = string.data[1:ncodeunits(string)]

Base.@propagate_inbounds function Base.codeunit(string::CStaticString, index::Int)
    @boundscheck 1 <= index <= ncodeunits(string) || throw_bounds_error(string, index)
    return @inbounds string.data[index]
end

"""
    PaddedStaticString{N,PAD}(data::NTuple{N,UInt8})
    padded"string[PAD]"[N]

Store up to `N` logical bytes with trailing `PAD` bytes excluded from the content.

Internal `PAD` bytes remain content. NUL bytes remain content unless they are
trailing and `PAD == 0`. Inputs longer than `N` bytes are rejected.
The literal uses its last code unit as `PAD` and infers `N` from its unescaped
byte length when the capacity is omitted.
"""
struct PaddedStaticString{N,PAD} <: AbstractStaticString{N}
    data::NTuple{N,UInt8}
    function PaddedStaticString{N,PAD}(data::NTuple{M,UInt8}) where {N,M,PAD}
        M <= N || throw(InexactError(:PaddedStaticString, PaddedStaticString{N, PAD}, data))
        _data = ntuple(i->i <= M ? data[i] : UInt8(PAD), Val(N))
        return new{N,UInt8(PAD)}(_data)
    end
    function PaddedStaticString{N,PAD}(s::AbstractString) where {N,PAD}
        M = ncodeunits(s)
        M <= N || throw(InexactError(:PaddedStaticString, PaddedStaticString{N, PAD}, s))
        codeunit(s) == UInt8 || throw(ArgumentError("Only strings with UInt8 codeunits can be padded"))
        _data = ntuple(i -> i <= M ? (@inbounds codeunit(s, i)) : UInt8(PAD), Val(N))
        return new{N,UInt8(PAD)}(_data)
    end
    PaddedStaticString{N,PAD}(data::Tuple{}) where {N,PAD} = new{N,UInt8(PAD)}(ntuple(i->UInt8(PAD), Val(N)))
    PaddedStaticString{N}(data::AbstractString) where N = PaddedStaticString{N,0x0}(data)
    PaddedStaticString{N}(data::NTuple{M,UInt8} where M) where N = PaddedStaticString{N,0x0}(data)
    PaddedStaticString{N}(data::Tuple{}) where N = PaddedStaticString{N,0x0}(data)
end

"""
    StaticStrings.pad(string::PaddedStaticString)

Retrieve the UInt8 code unit used for padding.
"""
pad(string::PaddedStaticString{N,PAD} where N) where PAD = PAD::UInt8

function Base.ncodeunits(string::PaddedStaticString{N,PAD}) where {N,PAD}
    pos = findlast(!=(UInt8(PAD)), string.data)
    if isnothing(pos)
        return 0
    else
        return pos
    end
end
Base.codeunits(string::PaddedStaticString) = string.data[1:ncodeunits(string)]

Base.@propagate_inbounds function Base.codeunit(string::PaddedStaticString, index::Int)
    @boundscheck 1 <= index <= ncodeunits(string) || throw_bounds_error(string, index)
    return @inbounds string.data[index]
end

const StaticStringSubTypes = (StaticString, SubStaticString, CStaticString, PaddedStaticString)
