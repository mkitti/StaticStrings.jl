"""
    StaticStrings

Implements an `AbstractString` based on `NTuple{N,UInt8}`.

See `StaticString`, `CStaticString`
"""
module StaticStrings

using Compat

export StaticString, CStaticString, PaddedStaticString
export @Static_str, @CStatic_str, @Padded_str

include("types.jl")
include("abstractnstrings.jl")
include("comparison.jl")
include("strings.jl")
include("convert.jl")
include("macros.jl")

end # module NStrings
