"""
    StaticStrings.jl

The StaticStrings.jl package implements an `AbstractString` based on `NTuple{N,UInt8}`.

```jldoctest
julia> using StaticStrings

julia> static"Thank you for using StaticStrings.jl"
static"Thank you for using StaticStrings.jl"36

julia> static"Thank you for using StaticStrings.jl"64
static"Thank you for using StaticStrings.jl\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0"64

julia> StaticString((0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x20, 0x77, 0x6f, 0x72, 0x6c, 0x64))
static"Hello world"11
```

See [`StaticString`](@ref), [`SubStaticString`](@ref), [`CStaticString`](@ref), [`PaddedStaticString`](@ref)
"""
module StaticStrings

using Compat

export StaticString, SubStaticString, CStaticString, PaddedStaticString, WStaticString
export @static_str, @cstatic_str, @padded_str, @substatic_str, @wstatic_str
export @substatic

include("AbstractStaticString.jl")
include("types.jl")
include("comparison.jl")
include("strings.jl")
include("convert.jl")
include("macros.jl")
include("show.jl")
include("io.jl")

end # module NStrings
