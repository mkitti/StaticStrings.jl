using StaticStrings
using Test

@testset "ccall" begin
    @test ccall(:printf, Cint, (Ptr{Cchar},), CStatic"hello\n\0\0") == 6
    @test ccall(:printf, Cint, (Ptr{Cchar},), CStatic"hello\n\0") == 6
    @test ccall(:printf, Cint, (Ptr{Cchar},), CStatic"hello\n") == 6
end
