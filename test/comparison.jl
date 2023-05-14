using StaticStrings
using Test

@testset "Comparison" begin
    s = static"Hello"6
    @test s == s
    @test s != static"Hello"5
    @test s != static"World"6
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
    @test c == padded"el "5
    @test padded"Hello "20 == static"Hello"
    @test padded"Hello "20 != static"Hello"20
    @test padded"Hello\0"20 == static"Hello"
    @test padded"Hello\0"20 != static"Hello"6
    @test padded"Hello "20 == cstatic"Hello"10
    @test padded"Hello "10 == padded"Hello "5
    @test padded"Hello "10 == padded"Hello "6
    @test padded"Hello "10 != padded"Hello "4
    @test cstatic"Hello" == static"Hello"
    @test cstatic"Hello"10 == static"Hello"
    @test cstatic"Hello"10 == static"Hello"10
    @test cstatic"Hello"10 == static"Hello"5
    @test cstatic"Hello"10 == cstatic"Hello"5
    @test cstatic"Hello"10 == cstatic"Hello"6
    @test cstatic"Hello"10 == "Hello"
    @test String(cstatic"Hello"10) == "Hello\0\0\0\0\0"
    @test String(strip(cstatic"Hello"10)) == "Hello"
end
