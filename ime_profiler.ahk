ImeProfilerInitialize()
{
    global profiler := []
    ImeProfilerClear()
}

ImeProfilerClear()
{
    global profiler
    loop, 50
    {
        profiler[A_Index, 1] := 0   ; total tick
        profiler[A_Index, 2] := ""  ; debug info
        profiler[A_Index, 3] := 0   ; count
        profiler[A_Index, 4] := 0   ; last tick
    }
}

ImeProfilerSetDebugInfo(index, debug_info)
{
    global profiler
    profiler[index, 2] .= debug_info
}

ImeProfilerBegin(index)
{
    global profiler
    Assert(profiler[index, 4] == 0,,,true)
    profiler[index, 3] += 1
    profiler[index, 4] := A_TickCount
}

ImeProfilerEnd(index, debug_info:="")
{
    global profiler
    Assert(profiler[index, 4] != 0,,,true)
    profiler[index, 1] += A_TickCount - profiler[index, 4]
    profiler[index, 2] .= debug_info
    profiler[index, 4] := 0
}

ImeProfilerGetTotalTick(index)
{
    global profiler
    return profiler[index, 1]
}

ImeProfilerGetDebugInfo(index)
{
    global profiler
    return profiler[index, 2]
}

ImeProfilerGetCount(index)
{
    global profiler
    return profiler[index, 3]
}
