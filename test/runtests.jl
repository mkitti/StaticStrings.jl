using StaticStrings
using Test

@testset "StaticStrings.jl" begin
    include("construction.jl")
    include("convert.jl")
    include("comparison.jl")
    include("ccall.jl")
    include("show.jl")
    include("macros.jl")
    include("io.jl")
    include("ambiguities.jl")
    include("AbstractStaticString.jl")
    include("inlinestrings.jl")
    include("statictools.jl")
end
