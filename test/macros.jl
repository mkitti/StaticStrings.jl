using StaticStrings
using Test

# precompile
Static"Lorem ipsum dolor sit amet "
Short"Lorem ipsum dolor sit amet "
Long"Lorem ipsum dolor sit amet "
CStatic"Lorem ipsum dolor sit amet\0"
@static if VERSION >= v"1.6"
    Static"Lorem ipsum dolor sit amet"31
    Short"Lorem ipsum dolor sit amet"31
    Long"Lorem ipsum dolor sit amet"31
    CStatic"Lorem ipsum dolor sit amet"31
    Padded"Lorem ipsum dolor sit amet "31
end

@testset "Macros" begin
    @test @allocated(Static"Lorem ipsum dolor sit amet") == 0
    @test @allocated(Short"Lorem ipsum dolor sit amet") == 0
    @test @allocated(Long"Lorem ipsum dolor sit amet") == 0
    @test @allocated(CStatic"Lorem ipsum dolor sit amet") == 0
    @static if VERSION >= v"1.6"
        @test @allocated(Static"Lorem ipsum dolor sit amet"31) == 0
        @test @allocated(Short"Lorem ipsum dolor sit amet"31) == 0
        @test @allocated(Long"Lorem ipsum dolor sit amet"31) == 0
        @test @allocated(CStatic"Lorem ipsum dolor sit amet"31) == 0
        @test @allocated(Padded"Lorem ipsum dolor sit amet "31) == 0
    end
end
