using StaticStrings
using Test

@testset "show" begin
    io = IOBuffer()
    m = MIME"text/plain"()
    show(io, m, Static"Hello")
    @test String(take!(io)) == "Static\"Hello\"5"
    show(io, m, Short"Hello")
    @test String(take!(io)) == "Short\"Hello\"5"
    show(io, m, Long"Hello")
    @test String(take!(io)) == "Long\"Hello\"5"
    show(io, m, CStatic"Hello")
    @test String(take!(io)) == "CStatic\"Hello\"5"
    show(io, m, Padded"Hello "20)
    @test String(take!(io)) == "Padded\"Hello \"20"
end
