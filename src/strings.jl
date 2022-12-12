# This section is copied nearly verbatim from Julia base
# https://github.com/JuliaLang/julia/blob/24cb92d1e94367c5ef758545b69133ded4559763/base/strings/string.jl

import Base: between, _string_n

## thisind, nextind ##

Base.thisind(s::AbstractStaticString{N}, i::Int) where N = _thisind_str(s,i)

@inline function _thisind_str(s, i::Int)
    i == 0 && return 0
    n = ncodeunits(s)
    i == n + 1 && return i
    @boundscheck between(i, 1, n) || throw(BoundsError(s, i))
    @inbounds b = codeunit(s, i)
    (b & 0xc0 == 0x80) & (i-1 > 0) || return i
    @inbounds b = codeunit(s, i-1)
    between(b, 0b11000000, 0b11110111) && return i-1
    (b & 0xc0 == 0x80) & (i-2 > 0) || return i
    @inbounds b = codeunit(s, i-2)
    between(b, 0b11100000, 0b11110111) && return i-2
    (b & 0xc0 == 0x80) & (i-3 > 0) || return i
    @inbounds b = codeunit(s, i-3)
    between(b, 0b11110000, 0b11110111) && return i-3
    return i
end

Base.@propagate_inbounds Base.nextind(s::AbstractStaticString{N}, i::Int) where N = _nextind_str(s, i)

@inline function _nextind_str(s, i::Int)
    i == 0 && return 1
    n = ncodeunits(s)
    @boundscheck between(i, 1, n) || throw(BoundsError(s, i))
    @inbounds l = codeunit(s, i)
    (l < 0x80) | (0xf8 ≤ l) && return i+1
    if l < 0xc0
        i′ = @inbounds thisind(s, i)
        return i′ < i ? @inbounds(nextind(s, i′)) : i+1
    end
    # first continuation byte
    (i += 1) > n && return i
    @inbounds b = codeunit(s, i)
    b & 0xc0 ≠ 0x80 && return i
    ((i += 1) > n) | (l < 0xe0) && return i
    # second continuation byte
    @inbounds b = codeunit(s, i)
    b & 0xc0 ≠ 0x80 && return i
    ((i += 1) > n) | (l < 0xf0) && return i
    # third continuation byte
    @inbounds b = codeunit(s, i)
    ifelse(b & 0xc0 ≠ 0x80, i, i+1)
end

Base.byte_string_classify(s::AbstractStaticString{N}) where N =
    ccall(:u8_isvalid, Int32, (Ptr{UInt8}, Int), Ref(s), N)

@inline function Base.iterate(s::AbstractStaticString{N}, i::Int=firstindex(s)) where N
    (i % UInt) - 1 < ncodeunits(s) || return nothing
    b = @inbounds codeunit(s, i)
    u = UInt32(b) << 24
    between(b, 0x80, 0xf7) || return reinterpret(Char, u), i+1
    return iterate_continued(s, i, u)
end

function iterate_continued(s::AbstractStaticString{N}, i::Int, u::UInt32) where N
    u < 0xc0000000 && (i += 1; @goto ret)
    n = ncodeunits(s)
    # first continuation byte
    (i += 1) > n && @goto ret
    @inbounds b = codeunit(s, i)
    b & 0xc0 == 0x80 || @goto ret
    u |= UInt32(b) << 16
    # second continuation byte
    ((i += 1) > n) | (u < 0xe0000000) && @goto ret
    @inbounds b = codeunit(s, i)
    b & 0xc0 == 0x80 || @goto ret
    u |= UInt32(b) << 8
    # third continuation byte
    ((i += 1) > n) | (u < 0xf0000000) && @goto ret
    @inbounds b = codeunit(s, i)
    b & 0xc0 == 0x80 || @goto ret
    u |= UInt32(b); i += 1
@label ret
    return reinterpret(Char, u), i
end

Base.@propagate_inbounds function Base.getindex(s::AbstractStaticString, i::Int)
    b = codeunit(s, i)
    u = UInt32(b) << 24
    between(b, 0x80, 0xf7) || return reinterpret(Char, u)
    return getindex_continued(s, i, u)
end

function getindex_continued(s::AbstractStaticString{N}, i::Int, u::UInt32) where N
    if u < 0xc0000000
        # called from `getindex` which checks bounds
        @inbounds isvalid(s, i) && @goto ret
        string_index_err(s, i)
    end
    n = ncodeunits(s)

    (i += 1) > n && @goto ret
    @inbounds b = codeunit(s, i) # cont byte 1
    b & 0xc0 == 0x80 || @goto ret
    u |= UInt32(b) << 16

    ((i += 1) > n) | (u < 0xe0000000) && @goto ret
    @inbounds b = codeunit(s, i) # cont byte 2
    b & 0xc0 == 0x80 || @goto ret
    u |= UInt32(b) << 8

    ((i += 1) > n) | (u < 0xf0000000) && @goto ret
    @inbounds b = codeunit(s, i) # cont byte 3
    b & 0xc0 == 0x80 || @goto ret
    u |= UInt32(b)
@label ret
    return reinterpret(Char, u)
end

Base.getindex(s::AbstractStaticString, r::AbstractUnitRange{<:Integer}) = s[Int(first(r)):Int(last(r))]

@inline function Base.getindex(s::AbstractStaticString, r::UnitRange{Int})
    isempty(r) && return ""
    i, j = first(r), last(r)
    @boundscheck begin
        checkbounds(s, r)
        @inbounds isvalid(s, i) || string_index_err(s, i)
        @inbounds isvalid(s, j) || string_index_err(s, j)
    end
    j = nextind(s, j) - 1
    n = j - i + 1
    ss = _string_n(n)
    rs = Ref(s)
    GC.@preserve rs ss unsafe_copyto!(pointer(ss), Ptr{UInt8}(pointer_from_objref(rs)) + i-1, n)
    return ss
end
if VERSION <= v"1.8"
    # Remove ambiguity
    @inline function Base.getindex(s::AbstractStaticString, r::UnitRange{<:Integer})
        Base.getindex(s, UnitRange{Int}(r))
    end
end

Base.length(s::AbstractStaticString{N}) where N = length_continued(s, 1, ncodeunits(s), ncodeunits(s))

@inline function Base.length(s::AbstractStaticString{N}, i::Int, j::Int) where N
    @boundscheck begin
        0 < i ≤ ncodeunits(s)+1 || throw(BoundsError(s, i))
        0 ≤ j < ncodeunits(s)+1 || throw(BoundsError(s, j))
    end
    j < i && return 0
    @inbounds i, k = thisind(s, i), i
    c = j - i + (i == k)
    length_continued(s, i, j, c)
end

@inline function length_continued(s::AbstractStaticString, i::Int, n::Int, c::Int)
    i < n || return c
    @inbounds b = codeunit(s, i)
    @inbounds while true
        while true
            (i += 1) ≤ n || return c
            0xc0 ≤ b ≤ 0xf7 && break
            b = codeunit(s, i)
        end
        l = b
        b = codeunit(s, i) # cont byte 1
        c -= (x = b & 0xc0 == 0x80)
        x & (l ≥ 0xe0) || continue

        (i += 1) ≤ n || return c
        b = codeunit(s, i) # cont byte 2
        c -= (x = b & 0xc0 == 0x80)
        x & (l ≥ 0xf0) || continue

        (i += 1) ≤ n || return c
        b = codeunit(s, i) # cont byte 3
        c -= (b & 0xc0 == 0x80)
    end
end

## overload methods for efficiency ##

Base.isvalid(s::AbstractStaticString, i::Int) = checkbounds(Bool, s, i) && thisind(s, i) == i

function Base.isascii(s::AbstractStaticString{N}) where N
    @inbounds for i = 1:ncodeunits(s)
        codeunit(s, i) >= 0x80 && return false
    end
    return true
end


