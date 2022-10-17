using StaticStrings
using Test

# precompile

@testset "Macros" begin
    @test @static_str("Hello", 10) == "Hello\0\0\0\0\0"
    @test @cstatic_str("Hello", 10) == "Hello"
    @test @substatic_str("Hello", 10) == "Hello"
    @test @padded_str("Hello ", 10) == "Hello"
end
@static if VERSION ≥ v"1.7"
    include("post_julia_1_6/macros.jl")
end
