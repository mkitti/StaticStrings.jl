using StaticStrings
using Test

@testset "Comparison" begin
    s = static"Hello"
    @test s == s
    a = SubStaticString("hello",1:2)
    b = SubStaticString("hello",3:4)
    @test a == a
    @test b == b
    @test a != b
    @test a == "he"
    @test b == "ll"
    @test a == static"he"
    @test b == cstatic"ll"
    @test a != static"hello"
    @test b != static"hello"
    @test b != "hello"
    @test static"he" == cstatic"he"
    @test static"hello" != a
    @test static"hello" != b
    c = @substatic(static"Hello"[2:3])
    @test c == static"el"
    @test c != static"He"
    @test c != cstatic"ll"
    @test c == static"Hello"[2:3]
    @test cstatic"Hello" == static"Hello"
end

@static if VERSION ≥ v"1.6"
    include("post_julia_1_6/comparison.jl")
end
