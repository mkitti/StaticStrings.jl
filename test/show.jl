using StaticStrings
using Test

@testset "Show" begin
    io = IOBuffer()
    m = MIME"text/plain"()
    show(io, m, Static"Hello")
    @test String(take!(io)) == "Static\"Hello\"5"
    show(io, m, SubStatic"Hello")
    @test String(take!(io)) == "SubStatic\"Hello\"5"
    show(io, m, CStatic"Hello")
    @test String(take!(io)) == "CStatic\"Hello\"5"
end
@static if VERSION >= v"1.6"
    include("post_julia_1_6/show.jl")
end

