using StaticStrings
using Test

@testset "AbstractStaticString" begin
    @test ncodeunits(StaticString{5}) == 5
    @test ncodeunits(static"Hello") == 5
    @test codeunits(static"Hello") == (0x48, 0x65, 0x6c, 0x6c, 0x6f)
    @test codeunit(static"Hello") == UInt8
    @test codeunit(static"Hello",5) == 0x6f
    @test widen(static"Hello") === "Hello"
    @test widen(StaticString{5}) == String
end

copy_substatic_codeunits!(output, string::SubStaticString) =
    map!(index -> codeunit(string, index), output, eachindex(output))

@testset "SubStaticString codeunit" begin
    bytes = "xα\0y" |> codeunits |> Tuple
    for ranges in ([1:stop for stop in 0:5], [2:stop for stop in 1:5],
                   [UInt8(2):stop for stop in UInt8(1):UInt8(5)],
                   [Base.OneTo(stop) for stop in UInt8(0):UInt8(5)])
        for range in ranges
            string = SubStaticString(bytes, range)
            output = Vector{UInt8}(undef, length(range))
            copy_substatic_codeunits!(output, string)
            @test (@allocated copy_substatic_codeunits!(output, string)) == 0
            @test Tuple(output) == bytes[range]
            isempty(range) && @test_throws BoundsError codeunit(string, 1)
        end
    end
    @test_throws BoundsError codeunit(SubStaticString(), 1)
    @test_throws BoundsError codeunit(SubStaticString(bytes, 99:98), 1)
    string = SubStaticString(bytes, 2:4)
    for index in (typemin(Int), -1, 0, ncodeunits(string) + 1, typemax(Int))
        @test_throws BoundsError codeunit(string, index)
    end
    @test codeunit(string, UInt8(2)) == 0xb1
    @test collect(string) == ['α', '\0']
end