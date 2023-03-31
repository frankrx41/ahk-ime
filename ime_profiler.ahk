ImeProfilerInitialize()
{
    global ime_profiler := []
    ImeProfilerClear()
}

ImeProfilerClear()
{
    global ime_profiler
    loop, 50
    {
        ime_profiler[A_Index, 1] := 0   ; total tick
        ime_profiler[A_Index, 2] := ""  ; debug info
        ime_profiler[A_Index, 3] := 0   ; count
        ime_profiler[A_Index, 4] := 0   ; last tick
    }
}

ImeProfilerBegin(index, clear_info:=false)
{
    global ime_profiler
    Assert(ime_profiler[index, 4] == 0,index,true)
    if( clear_info ) {
        ime_profiler[index, 2] := ""
    }
    ime_profiler[index, 3] += 1
    ime_profiler[index, 4] := A_TickCount
}

ImeProfilerEnd(index, debug_info:="")
{
    global ime_profiler
    Assert(ime_profiler[index, 4] != 0, "`nCall ``ImeProfilerEnd`` without ``ImeProfilerBegin``: " index,true)
    ime_profiler[index, 1] += A_TickCount - ime_profiler[index, 4]
    ime_profiler[index, 2] .= debug_info
    ime_profiler[index, 4] := 0
}

ImeProfilerGetTotalTick(index)
{
    global ime_profiler
    return ime_profiler[index, 1]
}

ImeProfilerGetDebugInfo(index)
{
    global ime_profiler
    return ime_profiler[index, 2]
}

ImeProfilerGetCount(index)
{
    global ime_profiler
    return ime_profiler[index, 3]
}
