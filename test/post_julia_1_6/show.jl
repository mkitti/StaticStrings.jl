@testset "Show Post Julia 1.6" begin
    io = IOBuffer()
    m = MIME"text/plain"()
    show(io, m, padded"Hello "20)
    @test String(take!(io)) == "padded\"Hello \"20"
end
