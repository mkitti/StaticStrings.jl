using StaticStrings
using Test

@testset "IO" begin
    io = IOBuffer(repeat([[UInt8(x) for x in "ba"]; 0x00], 3))
    @test read(io, StaticString{3}) == static"ba\0"
    @test read(io, CStaticString{3}) == cstatic"ba"
    @test read(io, CStaticString) == cstatic"ba"
    io = IOBuffer(UInt8['h', 'e', 'l', 'l', 'o', 0x0, 'b', 'y', 'e', 0x0])
    @test read(io, StaticString{6}) == static"hello\0"
    @test read(io, StaticString{4}) == static"bye\0"
    seekstart(io)
    @test read(io, CStaticString{6}) == static"hello\0"
    @test read(io, CStaticString{4}) == static"bye\0"
    seekstart(io)
    @test read(io, CStaticString) == cstatic"hello"
    @test read(io, CStaticString) == cstatic"bye"
    seekstart(io)
    @test read(io, CStaticString; sizehint=6) == static"hello\0"
    @test read(io, CStaticString; sizehint=4) == static"bye\0"
    seekstart(io)
    @test read(io, CStaticString; sizehint=3) == static"hello\0"
    @test read(io, CStaticString; sizehint=3) == static"bye\0"
    io = IOBuffer()
    @test write(io, cstatic"Hello World") == 12
    @test write(io, static"Hola Mundo\0\0") == 12
    seekstart(io)
    @test read(io, CStaticString) == cstatic"Hello World"
    @test read(io, CStaticString) == cstatic"Hola Mundo"
    seekstart(io)
    @test read(io, StaticString{6}) == static"Hello "
    @test read(io, StaticString{6}) == static"World\0"
    @test read(io, StaticString{5}) == static"Hola "
    @test read(io, StaticString{6}) == static"Mundo\0"
end
