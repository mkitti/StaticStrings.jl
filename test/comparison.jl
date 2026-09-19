using StaticStrings
using Test

function compare_pairs!(output, left, right)
    for index in eachindex(output, left, right)
        output[index] = left[index] == right[index]
    end
    return nothing
end

@testset "SubStaticString equality" begin
    for (left, right, expected) in (
        (SubStaticString("\xffa\xff", 2:2), SubStaticString("a\0", Base.OneTo(UInt8(1))), true),
        (SubStaticString("ab", 1:2), SubStaticString("ac", 1:2), false),
        (SubStaticString("\xff", 99:98), SubStaticString(), true),
        (SubStaticString("a\0", 1:1), CStaticString("a\0"), false),
        (SubStaticString("a\0", 1:2), CStaticString("a\0"), true),
        (SubStaticString("\xffa", UInt8(2):UInt8(2)), PaddedStaticString{3,0xff}("a"), true),
        (SubStaticString("\u03b1", 2:2), StaticString("\xb1"), true),
    )
        @test (left == right) == expected
        @test (right == left) == expected
    end
    bytes = Tuple(codeunits("abcdefghijklmnopqrstuvwxyzABCDEFG"))
    left = [SubStaticString(bytes, 2:mod(index, 33) + 1) for index in 1:256]
    right = copy(left)
    right[2:2:end] = reverse(right[2:2:end])
    output = fill(false, length(left))
    expected = [codeunits(first) == codeunits(second) for (first, second) in zip(left, right)]
    compare_pairs!(output, left, right)
    @test output == expected
    @test (@allocated compare_pairs!(output, left, right)) == 0
end

@testset "Active-range ordering" begin
    strings = (
        (SubStaticString("a\0", Base.OneTo(UInt8(1))), "a"),
        (SubStaticString("a\xff", Base.OneTo(UInt8(1))), "a"),
        (SubStaticString("\xffa\xff", 2:2), "a"),
        (SubStaticString("\xffab", UInt8(2):UInt8(3)), "ab"),
        (SubStaticString("\0b", 2:2), "b"),
        (SubStaticString("\xff", 99:98), ""),
        (SubStaticString(), ""),
        (SubStaticString("\xffa\0", 2:3), "a\0"),
        (SubStaticString("\xff\u03b1", 2:3), "\u03b1"),
        (StaticString("a"), "a"),
        (CStaticString("a\0"), "a"),
        (PaddedStaticString{3,0xff}("a"), "a"),
    )
    for (left, left_text) in strings, (right, right_text) in strings
        @test sign(cmp(left, right)) == sign(cmp(left_text, right_text))
    end
end

@testset "Comparison" begin
    s = static"Hello"
    @test s == s
    a = SubStaticString("hello",1:2)
    b = SubStaticString("hello",3:4)
    @test a == a
    @test b == b
    @test a != b
    @test a == "he"
    @test b == "ll"
    @test a == static"he"
    @test b == cstatic"ll"
    @test a != static"hello"
    @test b != static"hello"
    @test b != "hello"
    @test static"he" == cstatic"he"
    @test static"hello" != a
    @test static"hello" != b
    c = @substatic(static"Hello"[2:3])
    @test c == static"el"
    @test c != static"He"
    @test c != cstatic"ll"
    @test c == static"Hello"[2:3]
    @test cstatic"Hello" == static"Hello"
    for (left, right) in ((StaticString("a"), CStaticString("a\0")),
                          (StaticString("a\0"), CStaticString("a\0")),
                          (CStaticString("a\0"), CStaticString("a\0\0")),
                          (PaddedStaticString{3,0x00}("a"), CStaticString("a\0")))
        @test left == right
        @test right == left
    end
end

@static if VERSION ≥ v"1.6"
    include("post_julia_1_6/comparison.jl")
end
