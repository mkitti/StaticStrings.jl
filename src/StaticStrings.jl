"""
    StaticStrings.jl

The StaticStrings.jl package implements an `AbstractString` based on `NTuple{N,UInt8}`.

```jldoctest
julia> using StaticStrings

julia> Static"Thank you for using StaticStrings.jl"
Static"Thank you for using StaticStrings.jl"36

julia> Static"Thank you for using StaticStrings.jl"64
Static"Thank you for using StaticStrings.jl\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0"64

julia> StaticString((0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x20, 0x77, 0x6f, 0x72, 0x6c, 0x64))
Static"Hello world"11
```

See [`StaticString`](@ref), [`SubStaticString`](@ref), [`CStaticString`](@ref), [`PaddedStaticString`](@ref)
"""
module StaticStrings

using Compat

export StaticString, SubStaticString, CStaticString, PaddedStaticString
export @static_str, @cstatic_str, @padded_str, @substatic_str

include("AbstractStaticString.jl")
include("types.jl")
include("comparison.jl")
include("strings.jl")
include("convert.jl")
include("macros.jl")
include("show.jl")

end # module NStrings
