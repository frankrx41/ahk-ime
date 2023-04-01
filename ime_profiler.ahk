;*******************************************************************************
; This file use for profile
;
; To use it, try follow code
; ```
;   ImeProfilerBegin(YOUR_PROFILE_ID)
;   <The code you want to profile>
;   ImeProfilerEnd(YOUR_PROFILE_ID, YOUR_PROFILE_INFO)
; ```
; Then, goto ime_debug.ahk and add YOUR_PROFILE_ID use `ImeDebugTipAppend` in
; `ImeDebugGetDisplayText` function.
;
; * Call `ImeProfilerBegin` before call `ImeProfilerEnd`
; * Max number of `YOUR_PROFILE_ID` is 50.
; * "YOUR_PROFILE_INFO" will be stack, If you want to clear it every time you
; call it, try `ImeProfilerBegin(YOUR_PROFILE_ID, true)`
; * `ImeProfilerClear()` will clear all profile, this function will be call every
; time you type a new char or you delete any chars.
;*******************************************************************************
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

;*******************************************************************************
;
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
    Assert(ime_profiler[index, 4] != 0, "Please call ``ImeProfilerBegin(" index ")`` before call ``ImeProfilerEnd(" index ")``" ,true)
    ime_profiler[index, 1] += A_TickCount - ime_profiler[index, 4]
    ime_profiler[index, 2] .= debug_info
    ime_profiler[index, 4] := 0
}

;*******************************************************************************
; Use for print
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
