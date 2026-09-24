using StaticStrings
using Test

@testset "AbstractStaticString" begin
    @test ncodeunits(StaticString{5}) == 5
    @test ncodeunits(static"Hello") == 5
    @test codeunits(static"Hello") == Tuple(b"Hello")
    @test codeunit(static"Hello") == UInt8
    @test codeunit(static"Hello",5) == UInt8('o')
    @test widen(static"Hello") === "Hello"
    @test widen(StaticString{5}) == String
end

@testset "SubStaticString ncodeunits" begin
    source = "abc"
    for IntegerType in (Int, Int8, UInt8, Int64, UInt64, Int128, UInt128, BigInt)
        for range in (IntegerType(2):IntegerType(3), IntegerType(2):IntegerType(1),
                      Base.OneTo(IntegerType(3)), Base.OneTo(IntegerType(0)))
            string = SubStaticString(source, range)
            expected = UInt8[codeunit(source, Int(index)) for index in range]
            @test ncodeunits(string) === length(expected)
            @test collect(codeunits(string)) == expected
            @test String(string) == String(copy(expected))
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
    source = "xα\0y"
    bytes = codeunits(source)
    for ranges in ([1:stop for stop in 0:5], [2:stop for stop in 1:5],
                   [UInt8(2):stop for stop in UInt8(1):UInt8(5)],
                   [Base.OneTo(stop) for stop in UInt8(0):UInt8(5)])
        for range in ranges
            string = SubStaticString(source, range)
            output = Vector{UInt8}(undef, length(range))
            copy_substatic_codeunits!(output, string)
            @test (@allocated copy_substatic_codeunits!(output, string)) == 0
            @test output == bytes[range]
            isempty(range) && @test_throws BoundsError codeunit(string, 1)
        end
    end
    @test_throws BoundsError codeunit(SubStaticString(), 1)
    @test_throws BoundsError codeunit(SubStaticString(source, 99:98), 1)
    string = SubStaticString(source, 2:4)
    for index in (typemin(Int), -1, 0, ncodeunits(string) + 1, typemax(Int))
        @test_throws BoundsError codeunit(string, index)
    end
    @test codeunit(string, UInt8(2)) == 0xb1
    @test collect(string) == ['α', '\0']
end

@testset "PaddedStaticString codeunit" begin
    string = PaddedStaticString{8, 0xff}("xα\0y")
    @test codeunit(string, UInt8(3)) == 0xb1
    for index in (typemin(Int), -1, 0, ncodeunits(string) + 1, typemax(Int))
        @test_throws BoundsError codeunit(string, index)
    end
    @test_throws BoundsError codeunit(PaddedStaticString{0, 0xff}(()), 1)
    @test_throws BoundsError codeunit(PaddedStaticString{5, 0xff}(()), 1)
end

@testset "UTF-8 index errors" begin
    for text in (StaticString("αβ"), SubStaticString("xαβ!", 2:5),
                 CStaticString("αβ\0suffix"), padded"αβ ")
        for index in (2, 4, 2:3, 1:2, 1:4)
            @test_throws StringIndexError text[index]
        end
        @test text[1] == 'α'
        @test text[3] == 'β'
        @test text[1:3] == "αβ"
        @test text[3:3] == "β"
        @test_throws BoundsError text[5]
        @test_throws BoundsError text[1:5]
    end
end

@testset "Logical content boundaries" begin
    for (text, expected) in (
        (StaticString("a\0b"), "a\0b"),
        (SubStaticString("xa\0z", 2:3), "a\0"),
        (SubStaticString("\xffa", 2:2), "a"),
        (CStaticString("a\0\xff"), "a"),
        (CStaticString("\0abc"), ""),
        (padded"a\xff", "a"),
        (padded"a\0b\0", "a\0b"),
        (padded"a\0 ", "a\0"),
        (padded"a b ", "a b"),
        (StaticString("\xff"), "\xff"),
        (SubStaticString("a\xffb", 2:2), "\xff"),
        (StaticString(()), ""),
        (padded" ", ""),
        (SubStaticString("a", 99:98), ""),
    )
        @test ncodeunits(text) === ncodeunits(expected)
        @test collect(codeunits(text)) == collect(codeunits(expected))
        @test collect(text) == collect(expected)
        @test isvalid(String, text) == isvalid(String, expected)
        @test text[1:lastindex(text)] == expected
        @test_throws BoundsError codeunit(text, ncodeunits(text) + 1)
        @test_throws BoundsError text[ncodeunits(text) + 1]
    end
end