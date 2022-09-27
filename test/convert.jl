using NStrings
using Test

@testset "Conversion" begin
    hello_world = NString("hello world!")
    @test hello_world == "hello world!"
    hello_world_str = String(hello_world)
    @test hello_world_str isa String
    @test convert(String, hello_world) === hello_world_str
    @test convert(NMString, hello_world) == hello_world
    @test convert(Tuple, hello_world) == (0x68, 0x65, 0x6c, 0x6c, 0x6f, 0x20, 0x77, 0x6f, 0x72, 0x6c, 0x64, 0x21) 
    @test Tuple(hello_world) == (0x68, 0x65, 0x6c, 0x6c, 0x6f, 0x20, 0x77, 0x6f, 0x72, 0x6c, 0x64, 0x21)
end
