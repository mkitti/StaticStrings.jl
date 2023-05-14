using StaticStrings
using Test

# precompile

@testset "Macros" begin
    @test @static_str("Hello", 10) == "Hello\0\0\0\0\0"
    @test @cstatic_str("Hello", 10) == "Hello"
    @test @substatic_str("Hello", 10) == "Hello"
    @test @padded_str("Hello ", 10) == "Hello"
    @test @substatic(static"Hello"[2:3]) == "el"
    @test @substatic(static"Hello"[2:3]) != @substatic(static"Hello"[1:3])
    @test @substatic(static"Hello"[3:4]) == static"ll"
end
@static if VERSION ≥ v"1.7"
    include("post_julia_1_6/macros.jl")
end
