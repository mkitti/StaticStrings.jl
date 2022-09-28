## comparison ##

_memcmp(a::AbstractStaticString, b::AbstractStaticString, len) =
    ccall(:memcmp, Cint, (Ptr{UInt8}, Ptr{UInt8}, Csize_t), Ref(a), Ref(b), len % Csize_t) % Int

function _memcmp(a::AbstractStaticString, b::AbstractStaticString)
    al, bl = ncodeunits(a), ncodeunits(b)
    c = _memcmp(a, b, min(al,bl))
    return c < 0 ? -1 : c > 0 ? +1 : cmp(al,bl)
end

function Base.:(==)(a::AbstractStaticString, b::AbstractStaticString)
    data(a) == data(b) && return true
    al = ncodeunits(a)
    return al == ncodeunits(b) && 0 == _memcmp(a, b, al)
end

function Base.cmp(a::AbstractStaticString, b::AbstractStaticString)
    cmp(data(a), data(b))
end
