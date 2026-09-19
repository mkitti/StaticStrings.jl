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

@testset "Integer byte counts" begin
    text = SubStaticString((0x78, 0x61, 0x62, 0x63), 2:4)
    for IntegerType in (Int, Int8, UInt8, UInt64, Int128, UInt128, BigInt)
        for count in 0:3
            io = IOBuffer()
            @test StaticStrings.write_codeunits(io, text, IntegerType(count)) === count
            @test take!(io) == UInt8[0x61, 0x62, 0x63][1:count]
        end
        @test_throws BoundsError StaticStrings.write_codeunits(IOBuffer(), text, IntegerType(4))
    end
end

@testset "Byte write bounds" begin
    for text in (StaticString("abc"), SubStaticString((0x78, 0x61, 0x62, 0x63), 2:4),
                 PaddedStaticString{3,0x20}("a"), CStaticString("ab\0"))
        for count in (-1, typemin(Int), 4, typemax(UInt), big(2)^128)
            io = IOBuffer()
            @test_throws BoundsError StaticStrings.write_codeunits(io, text, count)
            @test position(io) == 0
        end
    end
    for start in (0, 99, Int128(typemin(Int)), UInt128(typemax(UInt)), big(2)^128)
        text = SubStaticString((0x61,), start:start-1)
        io = IOBuffer()
        @test StaticStrings.write_codeunits(io, text, 0) === 0
        @test_throws BoundsError StaticStrings.write_codeunits(io, text, 1)
        @test position(io) == 0
    end
    @test_throws BoundsError StaticStrings.write_codeunits(IOBuffer(), StaticString(""), 1)
end

@testset "Shared byte IO" begin
    for (text, printed, written) in (
        (StaticString(""), "", ""),
        (StaticString("α\0y"), "α\0y", "α\0y"),
        (StaticString((0xff, 0xce)), "\xff\xce", "\xff\xce"),
        (PaddedStaticString{5,0x20}(""), "", ""),
        (PaddedStaticString{8,0x20}("α\0y"), "α\0y", "α\0y"),
        (CStaticString(), "", "\0"),
        (CStaticString("\0\0"), "", "\0\0"),
        (CStaticString("α"), "α", "α\0"),
        (CStaticString("α\0\0"), "α", "α\0\0"))
        for operation in (print, write)
            expected = collect(codeunits(operation === print ? printed : written))
            strings = [text]
            io = IOBuffer(; sizehint=8)
            write_strings!(operation, io, strings)
            @test (@allocated write_strings!(operation, io, strings)) == 0
            for limit in (2, 8)
                io = IOBuffer(; maxsize=limit)
                count = min(limit, length(expected))
                @test operation(io, text) === (operation === print ? nothing : count)
                @test take!(io) == expected[1:count]
            end
            @static if isdefined(Base, :AnnotatedIOBuffer)
                io = IOBuffer()
                @test operation(Base.AnnotatedIOBuffer(io), text) ===
                      (operation === print ? nothing : length(expected))
                @test take!(io) == expected
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
    for operation in (write, print)
        io = IOBuffer(; maxsize=2)
        @test operation(io, text) === (operation === write ? 2 : nothing)
        @test take!(io) == collect(codeunits("α"))
        @static if isdefined(Base, :AnnotatedIOBuffer)
            io = IOBuffer()
            @test operation(Base.AnnotatedIOBuffer(io), text) === (operation === write ? 4 : nothing)
            @test take!(io) == collect(codeunits("α\0y"))
        end
    end
end
