using StaticStrings
using Test

# precompile

@testset "Macros" begin
    @test @static_str("Hello", 10) == "Hello\0\0\0\0\0"
    @test @cstatic_str("Hello", 10) == "Hello"
    @test @substatic_str("Hello", 10) == "Hello"
    @test @padded_str("Hello ", 10) == "Hello"
    @test @substatic(static"Hello"[2:3]) == "el"
    @test @substatic(static"Hello"[2:3]) != @substatic(static"Hello"[1:3])
    @test @substatic(static"Hello"[3:4]) == static"ll"
end
@static if VERSION ≥ v"1.7"
    include("post_julia_1_6/macros.jl")
end

@testset "Inferred padded capacity" begin
    for (text, explicit, bytes, content) in (
        (padded"Hello ", padded"Hello "6, "Hello ", "Hello"),
        (padded"Hello\0", padded"Hello\0"6, "Hello\0", "Hello"),
        (padded"α ", padded"α "3, "α ", "α"),
        (padded"a\0b\0\0", padded"a\0b\0\0"5, "a\0b\0\0", "a\0b"),
        (padded"\0", padded"\0"1, "\0", ""),
        (padded"a\xff", padded"a\xff"2, "a\xff", "a"),
    )
        @test text === explicit
        @test Tuple(text) === Tuple(codeunits(bytes))
        @test sizeof(typeof(text)) == ncodeunits(bytes)
        @test String(text) == content
    end
    @test ccall(:strlen, Csize_t, (Ptr{Cchar},), padded"Hello\0") == 5
    @test_throws ArgumentError macroexpand(@__MODULE__, :(padded""))
    @test_throws ArgumentError macroexpand(@__MODULE__, :(padded""5))
end
