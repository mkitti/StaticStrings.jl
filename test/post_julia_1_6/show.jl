@testset "Show Post Julia 1.6" begin
    io = IOBuffer()
    m = MIME"text/plain"()
    show(io, m, Padded"Hello "20)
    @test String(take!(io)) == "Padded\"Hello \"20"
end
