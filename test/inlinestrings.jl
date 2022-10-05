using Pkg
Pkg.add("InlineStrings")
using StaticStrings
using InlineStrings
using Test

@testset "InlineStrings.jl" begin
    static_string = Static"Hello"
    inline_string = InlineString(static_string)
    string15 = String15(static_string)
    @test static_string == inline_string
    @test string15 == inline_string
end
