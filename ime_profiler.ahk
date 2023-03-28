ImeProfilerInitialize()
{
    global profiler := []
    ImeProfilerReset()
}

ImeProfilerReset()
{
    global profiler
    loop, 50
    {
        profiler[A_Index] := 0
    }
}

ImeProfilerPlusTick(index, tick)
{
    global profiler
    if( index == 15 )
    {
        tick += 100
    }
    profiler[index] += tick
}
