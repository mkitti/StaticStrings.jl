@testset "Construction Post Julia 1.6" begin
    @test Static"Hello"6 === StaticString("Hello\0")
    @test CStatic"Hello"6 === CStaticString("Hello\0")
    hello_padded = Padded"Hello "10
    @test data(hello_padded) == (0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x20, 0x20, 0x20, 0x20, 0x20)
    @test Padded"Hello"4 == "Hell"
    @test Padded"Hello"5 == "Hell"
    @test data(Padded"Hello"5) == (0x48, 0x65, 0x6c, 0x6c, 0x6f)
    @test data(PaddedStaticString{10}("Hello")) == (0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x00, 0x00, 0x00, 0x00, 0x00)
    @test data(PaddedStaticString{10,0x19}("Hello")) == (0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x19, 0x19, 0x19, 0x19, 0x19)
    @test SubStatic"Hello"5 == "Hello"
    @test Padded"สวัสดีครับ "64 == "สวัสดีครับ"
end
