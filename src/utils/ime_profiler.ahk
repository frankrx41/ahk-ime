;*******************************************************************************
; This file use for profile
;
; To use it, try follow code
; ```
;   ImeProfilerBegin(<YOUR_PROFILE_ID>)
;   <The code you want to profile>
;   ImeProfilerEnd(<YOUR_PROFILE_ID>, <profile_text>)
; ```
;
; If you just want print some debug info, try
; ImeProfilerEnd(<YOUR_PROFILE_ID>, ImeProfilerBegin(<YOUR_PROFILE_ID>) "`n  - " <profile_text>)
;
; * Call `ImeProfilerBegin` before call `ImeProfilerEnd`
; * Max number of `YOUR_PROFILE_ID` is 50.
; * "YOUR_PROFILE_INFO" will be clear, If you want to stack it, you need to:
;   ```
;   <profile_text> := ImeProfilerBegin(<YOUR_PROFILE_ID>)
;   ImeProfilerEnd(<YOUR_PROFILE_ID>, "`n  - " <profile_text>)
;   ```
; * `ImeProfilerClear()` will clear all profile, this function will be call every
;   time you type a new char or you delete any chars.
;*******************************************************************************
ImeProfilerInitialize()
{
    global ime_profiler := {}
    ImeProfilerClear()
}

ImeProfilerClear()
{
    global ime_profiler := {}
}

;*******************************************************************************
;
ProfilerGetCallerName()
{
    return Exception("", -3).what "_"   ; force make name as string
}

ImeProfilerBeginName(name)
{
    global ime_profiler
    if( ime_profiler.HasKey(name) ) {
        Assert(ime_profiler[name, 4] == 0, "Please call ``ImeProfilerEnd(" name ")`` before call ``ImeProfilerBegin(" name ")``",true)
        ime_profiler[name, 3] += 1
        ime_profiler[name, 4] := A_TickCount
    } else {
        ime_profiler[name] := []
        ime_profiler[name, 1] := 0              ; total tick
        ime_profiler[name, 2] := ""             ; debug info
        ime_profiler[name, 3] := 1              ; trace count
        ime_profiler[name, 4] := A_TickCount    ; last tick
    }
    return ime_profiler[name, 2]
}

ImeProfilerEndName(name, profile_text)
{
    global ime_profiler
    Assert(ime_profiler.HasKey(name) && ime_profiler[name, 4] != 0, "Please call ``ImeProfilerBegin(" name ")`` before call ``ImeProfilerEnd(" name ")``" ,true)
    ime_profiler[name, 1] += A_TickCount - ime_profiler[name, 4]
    ime_profiler[name, 2] := profile_text
    ime_profiler[name, 4] := 0
}

;*******************************************************************************
;
ImeProfilerBegin()
{
    local
    name := ProfilerGetCallerName()
    return ImeProfilerBeginName(name)
}

ImeProfilerEnd(profile_text:="")
{
    local
    name := ProfilerGetCallerName()
    ImeProfilerEndName(name, profile_text)
}

ImeProfilerDebug(profile_text, append_text:=true)
{
    name := ProfilerGetCallerName()
    profile_text := ImeProfilerBeginName(name)
    profile_text := append_text ? profile_text : ""
    ImeProfilerEndName(name, profile_text)
}

ImeProfilerTemp(profile_text)
{
    ImeProfilerDebug("temp", profile_text)
}

ImeProfilerFunc(func_name)
{
    local
    name := ProfilerGetCallerName() . func_name
    profile_text := ImeProfilerBeginName(name)
    last_tick := A_TickCount
    Func(func_name).Call()
    profile_text .= "`n  - " func_name " (" A_TickCount - last_tick ")"
    ImeProfilerEndName(name, profile_text)
}

;*******************************************************************************
; Use for print
ImeProfilerGetTotalTick(name)
{
    global ime_profiler
    return ime_profiler.HasKey(name) ? ime_profiler[name, 1] : "N/A"
}

ImeProfilerGetDebugInfo(name)
{
    global ime_profiler
    return ime_profiler.HasKey(name) ? ime_profiler[name, 2] : "N/A"
}

ImeProfilerGetCount(name)
{
    global ime_profiler
    return ime_profiler.HasKey(name) ? ime_profiler[name, 3] : "N/A"
}

;*******************************************************************************
;
ImeProfilerInputBegin()
{
    global ime_profiler_timer
    ime_profiler_timer[1] := A_TickCount
}

ImeProfilerInputEnd()
{

}

