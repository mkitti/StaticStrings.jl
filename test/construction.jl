using StaticStrings
using StaticStrings: data
using Test

construct_substatic_strings!(output, bytes, ranges) =
    map!(range -> SubStaticString(bytes, range), output, ranges)

@testset "SubStaticString range validation" begin
    text = "xα\0y"
    bytes = text |> codeunits |> Tuple
    for range in (0:1, -1:0, 5:6, Base.OneTo(UInt8(6)), UInt8(4):UInt8(6))
        @test_throws ArgumentError SubStaticString(bytes, range)
    end
    @test SubStaticString{5}(bytes, 2:4).ind === 2:4
    @test_throws ArgumentError SubStaticString(bytes, 6)
    @test_throws ArgumentError SubStaticString{5}(StaticString(bytes), UInt8(6))
    @test_throws ArgumentError SubStaticString{5,UnitRange{Int}}(text, 1:6)
    @test SubStaticString((), 1:0).ind === 1:0
    @test_throws ArgumentError SubStaticString((), 1:1)

    for ranges in ([1:0, 1:5, 2:4, 6:5, 99:98],
                   [UInt8(2):stop for stop in UInt8(1):UInt8(5)],
                   [Base.OneTo(stop) for stop in UInt8(0):UInt8(5)])
        output = Vector{SubStaticString{5,eltype(ranges)}}(undef, length(ranges))
        construct_substatic_strings!(output, bytes, ranges)
        @test (@allocated construct_substatic_strings!(output, bytes, ranges)) == 0
        @test map(string -> string.ind, output) == ranges
        @test all(string -> data(string) === bytes, output)
        @test ncodeunits.(output) == length.(ranges)
    end
end

@testset "Constructon" begin
    hello = StaticString("hello")
    @test hello == "hello"
    hello0 = (hello.data..., 0x0)
    @test CStaticString(hello0) == "hello"
    @test CStaticString(hello0)[1:5] == hello
    @test static"Hello" === StaticString("Hello")
    @test cstatic"Hello\0" === CStaticString("Hello\0")
    @test data(hello) == data(hello)
    @test data(hello) isa NTuple{5, UInt8}
    @test data(hello) == (0x68, 0x65, 0x6c, 0x6c, 0x6f)
    @test_throws ArgumentError CStaticString("He\0llo\0")
    @test_throws ArgumentError CStaticString("He\0llo")
    @test CStaticString("Hell\0") == "Hell"
    @test "Hello" == "Hello"
    @test static"สวัสดีครับ" == "สวัสดีครับ"
    @test cstatic"สวัสดีครับ" == "สวัสดีครับ"
    @test substatic"สวัสดีครับ" == "สวัสดีครับ"
    @test StaticString{0}() == ""
    @test SubStaticString{0}() == ""
    @test CStaticString{0}() == ""
end
@static if VERSION ≥ v"1.6"
    include("post_julia_1_6/construction.jl")
end
