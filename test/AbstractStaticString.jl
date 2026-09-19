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

@testset "SubStaticString ncodeunits" begin
    bytes = (0x61, 0x62, 0x63)
    for IntegerType in (Int, UInt64, Int128, UInt128, BigInt)
        for range in (IntegerType(2):IntegerType(3), IntegerType(2):IntegerType(1),
                      Base.OneTo(IntegerType(3)), Base.OneTo(IntegerType(0)))
            string = SubStaticString(bytes, range)
            expected = UInt8[bytes[Int(index)] for index in range]
            @test ncodeunits(string) === length(expected)
            for operation in (print, write)
                io = IOBuffer()
                @test operation(io, string) === (operation === print ? nothing : length(expected))
                @test take!(io) == expected
            end
        end
    end
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

@testset "PaddedStaticString codeunit" begin
    string = PaddedStaticString{8,0xff}("xα\0y")
    @test codeunit(string, UInt8(3)) == 0xb1
    for index in (typemin(Int), -1, 0, ncodeunits(string) + 1, typemax(Int))
        @test_throws BoundsError codeunit(string, index)
    end
    @test_throws BoundsError codeunit(PaddedStaticString{0,0xff}(()), 1)
    @test_throws BoundsError codeunit(PaddedStaticString{5,0xff}(()), 1)
end