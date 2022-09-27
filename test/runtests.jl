using NStrings
using Test

@testset "NStrings.jl" begin
    include("construction.jl")
    include("convert.jl")
    include("ccall.jl")
end
