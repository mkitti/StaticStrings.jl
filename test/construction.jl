using StaticStrings
using StaticStrings: data
using Test

@testset "Constructon" begin
    hello = StaticString("hello")
    @test hello == "hello"
    hello0 = (hello.data..., 0x0)
    @test CStaticString(hello0) == "hello"
    @test CStaticString(hello0)[1:5] == hello
    @test Static"Hello" === StaticString("Hello")
    @test CStatic"Hello\0" === CStaticString("Hello\0")
    @test data(hello) == data(hello)
    @test data(hello) isa NTuple{5, UInt8}
    @test data(hello) == (0x68, 0x65, 0x6c, 0x6c, 0x6f)
    @test_throws ArgumentError CStaticString("He\0llo\0")
    @test_throws ArgumentError CStaticString("He\0llo")
    @test CStaticString("Hell\0") == "Hell"
    @test "Hello" == "Hello"
    @test Static"สวัสดีครับ" == "สวัสดีครับ"
    @test CStatic"สวัสดีครับ" == "สวัสดีครับ"
    @test SubStatic"สวัสดีครับ" == "สวัสดีครับ"
end
@static if VERSION ≥ v"1.6"
    include("post_julia_1_6/construction.jl")
end
