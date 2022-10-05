using StaticStrings
using Test

Static"Lorem ipsum dolor sit amet "
SubStatic"Lorem ipsum dolor sit amet "
CStatic"Lorem ipsum dolor sit amet\0"
Static"Lorem ipsum dolor sit amet"31
SubStatic"Lorem ipsum dolor sit amet"31
CStatic"Lorem ipsum dolor sit amet"31
Padded"Lorem ipsum dolor sit amet "31

@testset "Macros Post Julia 1.6" begin
    @test @allocated(Static"Lorem ipsum dolor sit amet") == 0
    @test @allocated(SubStatic"Lorem ipsum dolor sit amet") == 0
    @test @allocated(CStatic"Lorem ipsum dolor sit amet") == 0
    @test @allocated(Static"Lorem ipsum dolor sit amet"31) == 0
    @test @allocated(SubStatic"Lorem ipsum dolor sit amet"31) == 0
    @test @allocated(CStatic"Lorem ipsum dolor sit amet"31) == 0
    @test @allocated(Padded"Lorem ipsum dolor sit amet "31) == 0
end
