using StaticStrings
using Test

@testset "show" begin
    io = IOBuffer()
    show(io, Static"Hello")
    @test String(take!(io)) == "\"Hello\""
    show(io, CStatic"Hello")
    @test String(take!(io)) == "\"Hello\""
    show(io, Padded"Hello "20)
    @test String(take!(io)) == "\"Hello\""
end
