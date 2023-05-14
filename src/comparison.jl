## comparison ##
#
# 1. AbstractStaticStrings are equivalent if they have the same codeunits
# 2. AbstractStaticStrings are equivalent if they have the same codeunits up to ncodeunits
# 3. StaticStrings are equivalent to other StaticStrings with the same codeunits of the same size
# 4. CStaticStrings are equivalent to StaticStrings if they have the same codeunits (from #1)
# 5. CStaticStrings are equivalent to StaticStrings up to ncodeunits (from #2)

_memcmp(a::AbstractStaticString, b::AbstractStaticString, len) =
    ccall(:memcmp, Cint, (Ptr{UInt8}, Ptr{UInt8}, Csize_t), Ref(a), Ref(b), len % Csize_t) % Int

function _memcmp(a::AbstractStaticString, b::AbstractStaticString)
    al, bl = ncodeunits(a), ncodeunits(b)
    c = _memcmp(a, b, min(al,bl))
    return c < 0 ? -1 : c > 0 ? +1 : cmp(al,bl)
end

function Base.:(==)(a::AbstractStaticString, b::AbstractStaticString)
    codeunits(a) == codeunits(b) && return true
    al = ncodeunits(a)
    return al == ncodeunits(b) && 0 == _memcmp(a, b, al)
end
# For SubStaticString, just compare code units
@inline Base.:(==)(a::AbstractStaticString, b::SubStaticString) = codeunits(a) == codeunits(b)
@inline Base.:(==)(a::SubStaticString, b::AbstractStaticString) = codeunits(a) == codeunits(b)
@inline Base.:(==)(a::SubStaticString, b::SubStaticString) = codeunits(a) == codeunits(b)

function Base.cmp(a::AbstractStaticString, b::AbstractStaticString)
    cmp(data(a), data(b))
end
