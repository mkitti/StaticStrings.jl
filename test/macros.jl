using StaticStrings
using Test

# precompile

@testset "Macros" begin
    @test @Static_str("Hello", 10) == "Hello\0\0\0\0\0"
    @test @CStatic_str("Hello", 10) == "Hello"
    @test @SubStatic_str("Hello", 10) == "Hello"
    @test @Padded_str("Hello ", 10) == "Hello"
end
@static if VERSION ≥ v"1.6"
    include("post_julia_1_6/macros.jl")
end
