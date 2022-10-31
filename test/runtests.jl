using StaticStrings
using Test

@testset "StaticStrings.jl" begin
    include("construction.jl")
    include("convert.jl")
    include("ccall.jl")
    include("show.jl")
    include("macros.jl")
    include("io.jl")
    @static if VERSION ≥ v"1.6"
        include("inlinestrings.jl")
    end
    @static if VERSION ≥ v"1.7"
        include("statictools.jl")
    end
end
