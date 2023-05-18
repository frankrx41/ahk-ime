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
ImeProfilerBegin(index)
{
    global ime_profiler
    Assert(ime_profiler[index, 4] == 0, "Please call ``ImeProfilerEnd(" index ")`` before call ``ImeProfilerBegin(" index ")``",true)
    ime_profiler[index, 3] += 1
    ime_profiler[index, 4] := A_TickCount
    return ime_profiler[index, 2]
}

ImeProfilerEnd(index, profile_text:="")
{
    global ime_profiler
    Assert(ime_profiler[index, 4] != 0, "Please call ``ImeProfilerBegin(" index ")`` before call ``ImeProfilerEnd(" index ")``" ,true)
    ime_profiler[index, 1] += A_TickCount - ime_profiler[index, 4]
    ime_profiler[index, 2] := profile_text
    ime_profiler[index, 4] := 0
}

; ImeProfilerDebug(index, profile_text, stack:=true)
; {
;     global ime_profiler
;     ime_profiler[index, 1] += A_TickCount - ime_profiler[index, 4]
;     if( stack ){
;         ime_profiler[index, 2] .= profile_text
;     } else {
;         ime_profiler[index, 2] := profile_text
;     }
;     ime_profiler[index, 3] += 1
;     ime_profiler[index, 4] := 0
; }

ImeProfilerTemp(profile_text)
{
    ImeProfilerBegin(1)
    ImeProfilerEnd(1, profile_text)
}

ImeProfilerFunc(index, func_name)
{
    local
    profile_text := ImeProfilerBegin(index)
    last_tick := A_TickCount
    Func(func_name).Call()
    profile_text .= "`n  - " func_name " (" A_TickCount - last_tick ")"
    ImeProfilerEnd(index, profile_text)
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
