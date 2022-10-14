@testset "Construction Post Julia 1.6" begin
    @test static"Hello"6 === StaticString("Hello\0")
    @test cstatic"Hello"6 === CStaticString("Hello\0")
    hello_padded = padded"Hello "10
    @test data(hello_padded) == (0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x20, 0x20, 0x20, 0x20, 0x20)
    @test padded"Hello"4 == "Hell"
    @test padded"Hello"5 == "Hell"
    @test data(padded"Hello"5) == (0x48, 0x65, 0x6c, 0x6c, 0x6f)
    @test data(PaddedStaticString{10}("Hello")) == (0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x00, 0x00, 0x00, 0x00, 0x00)
    @test data(PaddedStaticString{10,0x19}("Hello")) == (0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x19, 0x19, 0x19, 0x19, 0x19)
    @test substatic"Hello"5 == "Hello"
    @test padded"สวัสดีครับ "64 == "สวัสดีครับ"
end
