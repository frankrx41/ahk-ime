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
