using Test
using StaticStrings

@test isempty(Test.detect_ambiguities(StaticStrings))

StaticString{20}(StaticString{5}("hello"))
SubStaticString{20, UnitRange}("Hello world", 1:5)
Base.unsafe_convert(Ptr{UInt8}, Ref(StaticString{11}("hello")))
PaddedStaticString{20, 'c'}(static"Hello")
StaticString(())
CStaticString{20}(())
CStaticString(())
CStaticString{0}(())
