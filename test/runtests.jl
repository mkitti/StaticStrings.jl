using StaticStrings
using Test

@testset "StaticStrings.jl" begin
    include("construction.jl")
    include("convert.jl")
    include("ccall.jl")
end
