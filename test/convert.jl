using StaticStrings
using Test

@testset "Conversion" begin
    hello_world = StaticString("hello world!")
    @test hello_world == "hello world!"
    hello_world_str = String(hello_world)
    @test hello_world_str isa String
    @test convert(String, hello_world) === hello_world_str
    @test convert(Tuple, hello_world) == (0x68, 0x65, 0x6c, 0x6c, 0x6f, 0x20, 0x77, 0x6f, 0x72, 0x6c, 0x64, 0x21) 
    @test Tuple(hello_world) == (0x68, 0x65, 0x6c, 0x6c, 0x6f, 0x20, 0x77, 0x6f, 0x72, 0x6c, 0x64, 0x21)
    hello_world0 = CStaticString("hello world!\0")
    GC.@preserve hello_world0 begin
        ptr = Base.unsafe_convert(Ptr{Cchar}, Base.cconvert(Ptr{UInt8}, hello_world0))
        @test Base.unsafe_string(ptr) == "hello world!"
    end
end
