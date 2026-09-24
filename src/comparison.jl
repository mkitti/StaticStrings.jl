## comparison ##

_memcmp(a::AbstractStaticString, b::AbstractStaticString, len) =
    ccall(:memcmp, Cint, (Ptr{UInt8}, Ptr{UInt8}, Csize_t), Ref(a), Ref(b), len % Csize_t) % Int

function _memcmp(a::AbstractStaticString, b::AbstractStaticString)
    al, bl = ncodeunits(a), ncodeunits(b)
    c = _memcmp(a, b, min(al,bl))
    return c < 0 ? -1 : c > 0 ? +1 : cmp(al,bl)
end

function Base.:(==)(a::AbstractStaticString, b::AbstractStaticString)
    (a isa SubStaticString || b isa SubStaticString) && return equal_codeunits(a, b)
    al = ncodeunits(a)
    return al == ncodeunits(b) && 0 == _memcmp(a, b, al)
end

function equal_codeunits(a::AbstractStaticString, b::AbstractStaticString)
    al, bl = ncodeunits(a), ncodeunits(b)
    al == bl || return false
    for index in 1:al
        left = @inbounds codeunit(a, index)
        right = @inbounds codeunit(b, index)
        left == right || return false
    end
    return true
end

function Base.cmp(a::AbstractStaticString, b::AbstractStaticString)
    al, bl = ncodeunits(a), ncodeunits(b)
    for index in 1:min(al, bl)
        left = @inbounds codeunit(a, index)
        right = @inbounds codeunit(b, index)
        left == right || return cmp(left, right)
    end
    return cmp(al, bl)
end
