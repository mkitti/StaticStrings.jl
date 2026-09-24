using StaticStrings
using Test

@testset "Logical content to String" begin
    for (string, expected) in ((StaticString(()), ""), (CStaticString(), ""),
                               (PaddedStaticString{0, '\0'}(()), ""),
                               (StaticString("a\0b"), "a\0b"),
                               (CStaticString("abc"), "abc"),
                               (CStaticString("abc\0"), "abc"),
                               (CStaticString("a\0\xff"), "a"),
                               (CStaticString("\0abc"), ""),
                               (StaticString("\xff"), "\xff"),
                               (padded"abc\0", "abc"),
                               (padded"a\0b\0", "a\0b"),
                               (padded"a\0 ", "a\0"),
                               (padded"a b ", "a b"),
                               (padded" ", ""),
                               (padded"abc\xff", "abc"))
        @test String(string) == expected
        @test convert(String, string) == expected
    end
end

@testset "SubStaticString to String" begin
    source = "xα\0y"
    for ranges in ([1:stop for stop in 0:5], [2:stop for stop in 1:5], [99:98],
                   [UInt8(2):stop for stop in UInt8(1):UInt8(5)],
                   [Base.OneTo(stop) for stop in UInt8(0):UInt8(5)])
        for range in ranges
            string = SubStaticString(source, range)
            expected = UInt8[codeunit(source, index) for index in range]
            @test collect(codeunits(String(string))) == expected
            @test convert(String, string) == String(expected)
        end
    end
    @test String(SubStaticString()) == ""
end

@testset "Conversion" begin
    hello_world = StaticString("hello world!")
    @test hello_world == "hello world!"
    for ss in (SubStaticString, CStaticString, PaddedStaticString{12})
        @test convert(ss, hello_world) == hello_world
    end
    hello_world_str = String(hello_world)
    @test hello_world_str isa String
    @test convert(String, hello_world) === hello_world_str
    @test convert(Tuple, hello_world) == Tuple(b"hello world!")
    @test Tuple(hello_world) == Tuple(b"hello world!")
    hello_world0 = CStaticString("hello world!\0")
    hello_world0c = Base.cconvert(Ptr{UInt8}, hello_world0)
    GC.@preserve hello_world0 hello_world0c begin
        ptr = Base.unsafe_convert(Ptr{Cchar}, hello_world0c)
        @test Base.unsafe_string(ptr) == "hello world!"
    end
    sss = @substatic(static"Hello"[3:4])
    substr = convert(SubString, sss)
    @test sss == substr
    @test substr.offset == 2
    @test substr.ncodeunits == 2
    @test typeof(substr) == SubString{StaticString{5}}
    sss2 = convert(SubStaticString, substr)
    @test sss == sss2
end
