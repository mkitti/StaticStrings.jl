"""
    AbstractNString{N}

Represents a string of N codeunits
"""
abstract type AbstractNString{N} <: AbstractString end

(ANS::Type{<:AbstractNString})(data::NTuple{N,Int8}) where N = ANS(UInt8.(data))

"""
    NString(data::NTuple{N,UInt8})

[`AbstractNString`](@ref) that wraps a NTuple{N,UInt8}.
"""
struct NString{N} <: AbstractNString{N}
    data::NTuple{N,UInt8}
end
data(nstring::NString) = nstring.data
ndata(nstring::NString) = nstring.data

"""
    CNString(data::NTuple{N,UInt8})

[`AbstractNString`](@ref) that wraps a NTuple{N,UInt8}.
"""
struct CNString{N} <: AbstractNString{N}
    data::NTuple{N,UInt8}
    function CNString(data::NTuple{N,UInt8}) where N
        findfirst(==(0x0), data) == N ||
            throw(ArgumentError("The data of a CNString must only contain a
                                terminal null byte at the end."))
        return new{N}(data)
    end
end
data(nstring::CNString) = nstring.data
ndata(nstring::CNString) = nstring.data

"""
    AbstractNMString{N,M}

[`AbstractNString`](@ref) that represents a string of N codeunits but contains M codeunits.
"""
abstract type AbstractNMString{N,M} <: AbstractNString{N} end

"""
    NMString{N,M}

[`AbstractNMString`](@ref) that represents a string of the first N codeunits but
contained within a `NTuple{M, UInt8}`
"""
struct NMString{N,M} <: AbstractNMString{N,M}
    data::NTuple{M,UInt8}
    function NMString(data::NTuple{M,UInt8}, N::Integer) where {M}
        N <= M || ArgumentError("N, $N, must be less than or equal to the length of $(typeof(data))")
        new{N, M}(data)
    end
end
function NMString(data::NTuple{M,UInt8}) where M
    N = findfirst(==(0x0), data)
    if isnothing(N)
        N = M
    end
    return NMString(data, N)
end

data(nstring::NMString) = nstring.data
ndata(nstring::NMString{N}) where N = nstring.data[1:N]

"""
    CNMString{N,M}

[`AbstractNMString`](@ref) that represents a string of the first N codeunits but
contained within a `NTuple{M, UInt8}` while containing no internal NULs having
a terminal NUL at codeunit N+1.
"""
struct CNMString{N,M} <: AbstractNMString{N,M}
    data::NTuple{M,UInt8}
    function CNMString(data::NTuple{NN,UInt8} where NN)
        M = findfirst(==(0x0), data)
        if isnothing(M)
            data = (data..., 0x0)
            M = length(data)
        else
            data = data[1:M]
        end
        N = M - 1
        new{N, M}(data)
    end
    function CNMString{N}(data::NTuple{M,UInt8}) where {N,M}
        M > N && data[N+1] == 0x0 || ArgumentError("data[$(N+1)] is not NUL")
        new{N, M}(data)
    end
end
data(nstring::CNMString) = nstring.data
ndata(nstring::CNMString{N}) where N = nstring.data[1:N]
