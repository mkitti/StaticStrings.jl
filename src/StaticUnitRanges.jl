module StaticUnitRanges
    export StaticUnitRange

    struct StaticUnitRange{START,STOP} <: AbstractUnitRange{Int} end
    Base.first(::StaticUnitRange{START}) where START = START
    Base.last(::StaticUnitRange{<: Any,STOP}) where {STOP} = STOP
end
