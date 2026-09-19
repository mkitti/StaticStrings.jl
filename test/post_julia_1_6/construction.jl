@testset "Construction Post Julia 1.6" begin
    @test static"Hello"6 === StaticString("Hello\0")
    @test cstatic"Hello"6 === CStaticString("Hello\0")
    hello_padded = padded"Hello "10
    @test Tuple(hello_padded) == Tuple(b"Hello     ")
    @test_throws InexactError PaddedStaticString{4, 'o'}("Hello")
    @test padded"Hello" == "Hell"
    @test Tuple(padded"Hello") == Tuple(b"Hello")
    @test Tuple(PaddedStaticString{10}("Hello")) == Tuple(b"Hello\0\0\0\0\0")
    @test Tuple(PaddedStaticString{10, 0x19}("Hello")) == Tuple(b"Hello\x19\x19\x19\x19\x19")
    @test substatic"Hello"5 == "Hello"
    @test padded"สวัสดีครับ " == "สวัสดีครับ"
end
