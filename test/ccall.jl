using NStrings
using Test

@testset "ccall" begin
    @test ccall(:printf, Cint, (Ptr{Cchar},), CN"hello\n\0") == 6
end
