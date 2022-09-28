"""
"""
module NStrings

using Compat

export NString, CNString
export data, ndata
export @N_str, @CN_str

include("types.jl")
include("abstractnstrings.jl")
include("comparison.jl")
include("strings.jl")
include("convert.jl")
include("macros.jl")

end # module NStrings
