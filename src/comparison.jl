## comparison ##

_memcmp(a::AbstractNString, b::AbstractNString, len) =
    ccall(:memcmp, Cint, (Ptr{UInt8}, Ptr{UInt8}, Csize_t), Ref(a), Ref(b), len % Csize_t) % Int

function _memcmp(a::AbstractNString, b::AbstractNString)
    al, bl = ncodeunits(a), ncodeunits(b)
    c = _memcmp(a, b, min(al,bl))
    return c < 0 ? -1 : c > 0 ? +1 : cmp(al,bl)
end

function Base.:(==)(a::AbstractNString, b::AbstractNString)
    ndata(a) == ndata(b) && return true
    al = ncodeunits(a)
    return al == ncodeunits(b) && 0 == _memcmp(a, b, al)
end

function Base.cmp(a::AbstractNString, b::AbstractNString)
    cmp(ndata(a), ndata(b))
end
