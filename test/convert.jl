using StaticStrings
using Test

@testset "SubStaticString to String" begin
    bytes = "xα\0y" |> codeunits |> Tuple
    for ranges in ([1:stop for stop in 0:5], [2:stop for stop in 1:5], [99:98],
                   [UInt8(2):stop for stop in UInt8(1):UInt8(5)],
                   [Base.OneTo(stop) for stop in UInt8(0):UInt8(5)])
        for range in ranges
            string = SubStaticString(bytes, range)
            expected = UInt8[bytes[index] for index in range]
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
    @test convert(Tuple, hello_world) == (0x68, 0x65, 0x6c, 0x6c, 0x6f, 0x20, 0x77, 0x6f, 0x72, 0x6c, 0x64, 0x21) 
    @test Tuple(hello_world) == (0x68, 0x65, 0x6c, 0x6c, 0x6f, 0x20, 0x77, 0x6f, 0x72, 0x6c, 0x64, 0x21)
    hello_world0 = CStaticString("hello world!\0")
    hello_world0c = Base.cconvert(Ptr{UInt8}, hello_world0)
    GC.@preserve hello_world0 hello_world0c begin
        ptr = Base.unsafe_convert(Ptr{Cchar}, hello_world0c)
        @test Base.unsafe_string(ptr) == "hello world!"
    end
    sss = @substatic(static"Hello"[3:4])
    substr = convert(SubString, sss)
    @test sss == substr
    @test substr.ncodeunits == 2
    sss2 = convert(SubStaticString, substr)
    @test sss == sss2
end
