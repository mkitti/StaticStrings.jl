using StaticStrings
using Test

@testset "Show" begin
    io = IOBuffer()
    m = MIME"text/plain"()
    show(io, m, static"Hello")
    @test String(take!(io)) == "static\"Hello\"5"
    show(io, m, substatic"Hello")
    @test String(take!(io)) == "substatic\"Hello\"5"
    show(io, m, cstatic"Hello")
    @test String(take!(io)) == "cstatic\"Hello\"5"
end
@static if VERSION >= v"1.6"
    include("post_julia_1_6/show.jl")
end

