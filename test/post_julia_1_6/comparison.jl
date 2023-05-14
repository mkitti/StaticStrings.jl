using StaticStrings
using Test

@testset "Comparison, post-1.6" begin
    s = static"Hello"6
    c = @substatic(static"Hello"[2:3])
    @test padded"Hello "20 == static"Hello"
    @test padded"Hello "20 != static"Hello"20
    @test padded"Hello\0"20 == static"Hello"
    @test padded"Hello\0"20 != static"Hello"6
    @test padded"Hello "20 == cstatic"Hello"10
    @test padded"Hello "10 == padded"Hello "5
    @test padded"Hello "10 == padded"Hello "6
    @test padded"Hello "10 != padded"Hello "4
    @test c == padded"el "5
    @test s != static"Hello"5
    @test s != static"World"6
    @test cstatic"Hello"10 == static"Hello"
    @test cstatic"Hello"10 == static"Hello"10
    @test cstatic"Hello"10 == static"Hello"5
    @test cstatic"Hello"10 == cstatic"Hello"5
    @test cstatic"Hello"10 == cstatic"Hello"6
    @test cstatic"Hello"10 == "Hello"
    @test String(cstatic"Hello"10) == "Hello\0\0\0\0\0"
    @test String(strip(cstatic"Hello"10)) == "Hello"
end
