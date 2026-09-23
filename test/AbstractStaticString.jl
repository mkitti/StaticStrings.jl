using StaticStrings
using Test

@testset "AbstractStaticString" begin
    @test ncodeunits(StaticString{5}) == 5
    @test ncodeunits(static"Hello") == 5
    @test codeunits(static"Hello") == (0x48, 0x65, 0x6c, 0x6c, 0x6f)
    @test codeunit(static"Hello") == UInt8
    @test codeunit(static"Hello",5) == 0x6f
    @test widen(static"Hello") === "Hello"
    @test widen(StaticString{5}) == String
end