using StaticStrings
using Test

function write_strings!(operation, io, strings)
    for string in strings
        truncate(io, 0)
        seekstart(io)
        operation(io, string)
    end
    return nothing
end

@testset "Allocation-free IO" begin
    bytes = "xα\0y" |> codeunits |> Tuple
    for strings in ([SubStaticString(bytes, 1:stop) for stop in 0:5],
                    [SubStaticString(bytes, 2:stop) for stop in 1:5],
                    [SubStaticString(bytes, UInt8(2):stop) for stop in UInt8(1):UInt8(5)],
                    [SubStaticString(bytes, Base.OneTo(stop)) for stop in UInt8(0):UInt8(5)],
                    [SubStaticString(), SubStaticString(bytes, 99:98)],
                    [PaddedStaticString{5,0xff}(bytes[1:stop]) for stop in 0:5])
        io = IOBuffer(; sizehint=5)
        for operation in (write, print)
            write_strings!(operation, io, strings)
            @testset "$(operation) $(eltype(strings))" begin
                @test (@allocated write_strings!(operation, io, strings)) == 0
            end
            for string in strings
                truncate(io, 0)
                seekstart(io)
                result = operation(io, string)
                @test result === (operation === write ? Int(ncodeunits(string)) : nothing)
                seekstart(io)
                @test Tuple(read(io)) == codeunits(string)
            end
        end
    end
end

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
    text = SubStaticString("xα\0y", 2:5)
    io = IOBuffer(; maxsize=2)
    @test write(io, text) == 2
    @test take!(io) == collect(codeunits("α"))
    @static if isdefined(Base, :AnnotatedIOBuffer)
        io = IOBuffer()
        @test write(Base.AnnotatedIOBuffer(io), text) == 4
        @test take!(io) == collect(codeunits("α\0y"))
    end
end
