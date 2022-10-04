"""
    StaticStrings

Implements an `AbstractString` based on `NTuple{N,UInt8}`.

See `StaticString`, `CStaticString`
"""
module StaticStrings

using Compat

export StaticString, CStaticString, PaddedStaticString
export ShortStaticString, LongStaticString
export @Static_str, @CStatic_str, @Padded_str
export @Short_str, @Long_str

include("types.jl")
include("abstractnstrings.jl")
include("comparison.jl")
include("strings.jl")
include("convert.jl")
include("macros.jl")
include("show.jl")

end # module NStrings
