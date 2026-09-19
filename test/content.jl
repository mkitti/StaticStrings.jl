using StaticStrings
using Test

@testset "Cross-type content consistency" begin
    examples = (
        (StaticString("a"), "a"),
        (StaticString("a\0"), "a\0"),
        (SubStaticString("xa\0z", 2:3), "a\0"),
        (CStaticString("a\0b"), "a"),
        (CStaticString("\0abc"), ""),
        (padded"a\xff", "a"),
        (padded"a\0b\0", "a\0b"),
        (StaticString("\xff"), "\xff"),
        (SubStaticString("a\xffb", 2:2), "\xff"),
    )
    for (text, expected) in examples
        for seed in (UInt(0), UInt(123))
            @test hash(text, seed) == hash(expected, seed)
        end
        @test haskey(Dict{Any, Int}(text => 1), expected)
        @test haskey(Dict{Any, Int}(expected => 1), text)
        @test expected in Set{Any}([text])
        for reference in (expected, SubString(expected))
            @test text == reference
            @test reference == text
            @test isequal(text, reference)
            @test cmp(text, reference) == cmp(reference, text) == 0
        end
        for (other, reference) in examples
            @test (text == other) == (expected == reference)
            @test isequal(text, other) == isequal(expected, reference)
            @test sign(cmp(text, other)) == sign(cmp(expected, reference))
            @test isless(text, other) == isless(expected, reference)
        end
    end
end