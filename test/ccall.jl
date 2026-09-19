using StaticStrings
using Test

@testset "ccall" begin
    @test ccall(:printf, Cint, (Ptr{Cchar},), cstatic"hello\n\0\0") == 6
    @test ccall(:printf, Cint, (Ptr{Cchar},), cstatic"hello\n\0") == 6
    @test ccall(:printf, Cint, (Ptr{Cchar},), cstatic"hello\n") == 6
end

@testset "Logical content pointers" begin
    for (text, expected) in ((SubStaticString("xabc!", 2:4), "abc"),
                             (CStaticString("abc\0\0"), "abc"),
                             (CStaticString("abc\0suffix"), "abc"),
                             (padded"abc ", "abc"),
                             (StaticString("abc"), "abc"),
                             (CStaticString(), ""),
                             (CStaticString("abc"), "abc"),
                             (CStaticString("\0suffix"), ""))
        owner = Base.cconvert(Ptr{UInt8}, text)
        GC.@preserve owner begin
            pointer = Base.unsafe_convert(Ptr{UInt8}, owner)
            GC.gc()
            @test unsafe_string(pointer, ncodeunits(text)) == expected
        end
        @test ccall(:strlen, Csize_t, (Cstring,), text) == ncodeunits(expected)
        if text isa CStaticString
            @test ccall(:strlen, Csize_t, (Ptr{UInt8},), text) == ncodeunits(expected)
        end
    end
    @test_throws ArgumentError ccall(:strlen, Csize_t, (Cstring,), StaticString("a\0b"))
end
