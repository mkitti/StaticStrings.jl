using StaticStrings
using Test

@testset "StaticStrings.jl" begin
    include("construction.jl")
    include("convert.jl")
    include("ccall.jl")
    include("show.jl")
    include("macros.jl")
    @static if VERSION ≥ v"1.6"
        include("inlinestrings.jl")
        include("statictools.jl")
    end
end
