using StaticStrings
using StaticTools
using Test

@testset "StaticTools.jl" begin
    static_string = Static"Hello"6
    tools_static_string = StaticTools.StaticString(Tuple(static_string))
    @test codeunits(static_string) == codeunits(tools_static_string)
end
