using StaticStrings
using Test

static"Lorem ipsum dolor sit amet "
substatic"Lorem ipsum dolor sit amet "
cstatic"Lorem ipsum dolor sit amet\0"
static"Lorem ipsum dolor sit amet"31
substatic"Lorem ipsum dolor sit amet"31
cstatic"Lorem ipsum dolor sit amet"31
padded"Lorem ipsum dolor sit amet "31

@testset "Macros Post Julia 1.7" begin
    @test @allocated(static"Lorem ipsum dolor sit amet") == 0
    @test @allocated(substatic"Lorem ipsum dolor sit amet") == 0
    @test @allocated(cstatic"Lorem ipsum dolor sit amet") == 0
    @test @allocated(static"Lorem ipsum dolor sit amet"31) == 0
    @test @allocated(substatic"Lorem ipsum dolor sit amet"31) == 0
    @test @allocated(cstatic"Lorem ipsum dolor sit amet"31) == 0
    @test @allocated(padded"Lorem ipsum dolor sit amet "31) == 0
end
