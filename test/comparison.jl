using StaticStrings
using Test

@testset "Active-range ordering" begin
    strings = (
        (SubStaticString("a\0", Base.OneTo(UInt8(1))), "a"),
        (SubStaticString("a\xff", Base.OneTo(UInt8(1))), "a"),
        (SubStaticString("\xffa\xff", 2:2), "a"),
        (SubStaticString("\xffab", UInt8(2):UInt8(3)), "ab"),
        (SubStaticString("\0b", 2:2), "b"),
        (SubStaticString("\xff", 99:98), ""),
        (SubStaticString(), ""),
        (SubStaticString("\xffa\0", 2:3), "a\0"),
        (SubStaticString("\xff\u03b1", 2:3), "\u03b1"),
        (StaticString("a"), "a"),
        (CStaticString("a\0"), "a"),
        (PaddedStaticString{3,0xff}("a"), "a"),
    )
    for (left, left_text) in strings, (right, right_text) in strings
        @test sign(cmp(left, right)) == sign(cmp(left_text, right_text))
    end
end

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
