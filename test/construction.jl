using NStrings
using Test

@testset "Constructon" begin
    hello = NString("hello")
    @test hello == "hello"
    hello0 = (hello.data..., 0x0)
    @test CNString(hello0) == "hello\0"
    @test CNString(hello0)[1:5] == hello
    @test NMString(hello) == hello
    @test NMString(hello.data) == hello
    @test CNMString(hello) == hello
    @test CNMString(hello.data) == hello
    @test N"Hello" === NString("Hello")
    @test CN"Hello\0" === CNString("Hello\0")
    @test data(hello) == ndata(hello)
    @test data(hello) isa NTuple{5, UInt8}
    @test ndata(hello) isa NTuple{5, UInt8}
    @test data(hello) == (0x68, 0x65, 0x6c, 0x6c, 0x6f)
    @test ndata(hello) == (0x68, 0x65, 0x6c, 0x6c, 0x6f)
end
