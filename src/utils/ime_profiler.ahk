;*******************************************************************************
; This file use for profile
;
; To use it, try follow code:
; ```
;   ImeProfilerBegin()
;   <The code you want to profile>
;   ImeProfilerEnd(<profile_text>)
; ```
;
; To get profile text, use:
; ```
;   ImeProfilerGetProfileText(<FUNCTION_NAME>_)
; ```
;
; * `ImeProfilerBegin` and `ImeProfilerEnd` must be in same function
; * Call `ImeProfilerBegin` before call `ImeProfilerEnd`
; * `ImeProfilerClear()` will clear all profile, this function will be call every
;   time you type a new char or you delete any chars.
;*******************************************************************************
ImeProfilerInitialize()
{
    global ime_profiler := {}
    ImeProfilerClear()
    ImeProfilerTickClear()
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

ImeProfilerBeginName(ByRef profiler, name)
{
    if( profiler.HasKey(name) ) {
        Assert(profiler[name, 4] == 0, "Please call ``ImeProfilerEnd(" name ")`` before call ``ImeProfilerBegin(" name ")``", true)
        profiler[name, 3] += 1
        profiler[name, 4] := A_TickCount
    } else {
        profiler[name] := []
        profiler[name, 1] := 0              ; total time
        profiler[name, 2] := ""             ; profile text
        profiler[name, 3] := 1              ; trace count
        profiler[name, 4] := A_TickCount    ; last tick
        profiler[name, 5] := 0              ; last time
    }
}

ImeProfilerEndName(ByRef profiler, name, profile_text, append)
{
    Assert(profiler.HasKey(name) && profiler[name, 4] != 0, "Please call ``ImeProfilerBegin(" name ")`` before call ``ImeProfilerEnd(" name ")``", true)
    profiler[name, 5] := A_TickCount - profiler[name, 4]
    profiler[name, 1] += profiler[name, 5]
    if( profile_text ) {
        profiler[name, 2] := append ? profiler[name, 2] "`n  - " : "  - "
        profiler[name, 2] .= profile_text
    }
    profiler[name, 4] := 0
}

;*******************************************************************************
;
ImeProfilerBegin()
{
    local
    global ime_profiler
    name := ProfilerGetCallerName()
    ImeProfilerBeginName(ime_profiler, name)
}

ImeProfilerEnd(profile_text:="", append:=true)
{
    local
    global ime_profiler
    name := ProfilerGetCallerName()
    ImeProfilerEndName(ime_profiler, name, profile_text, append)
}

ImeProfilerDebug(profile_text, append:=true)
{
    local
    global ime_profiler
    name := ProfilerGetCallerName()
    ImeProfilerBeginName(ime_profiler, name)
    ImeProfilerEndName(ime_profiler, name, profile_text, append)
}

ImeProfilerTemp(profile_text, append:=true)
{
    local
    global ime_profiler
    name := "Temporary_"
    ImeProfilerBeginName(ime_profiler, name)
    ImeProfilerEndName(ime_profiler, name, profile_text, append)
}

ImeProfilerFunc(func_name)
{
    local
    global ime_profiler
    name := ProfilerGetCallerName() . func_name
    ImeProfilerBeginName(ime_profiler, name)
    last_tick := A_TickCount
    Func(func_name).Call()
    profile_text := func_name " (" A_TickCount - last_tick ")"
    ImeProfilerEndName(ime_profiler, name, profile_text, true)
}

;*******************************************************************************
; Use for print
ImeProfilerHasKey(name)
{
    global ime_profiler
    return ime_profiler.HasKey(name)
}

ImeProfilerGetTotalTick(name)
{
    global ime_profiler
    Assert(ime_profiler.HasKey(name), name, false)
    return ime_profiler[name, 1]
}

ImeProfilerGetProfileText(name)
{
    global ime_profiler
    Assert(ime_profiler.HasKey(name), name, false)
    return ime_profiler[name, 2]
}

ImeProfilerGetCount(name)
{
    global ime_profiler
    Assert(ime_profiler.HasKey(name), name, false)
    return ime_profiler[name, 3]
}

;*******************************************************************************
;
ImeProfilerGetAllNameList()
{
    local
    global ime_profiler
    name_list := []
    for key, value in ime_profiler
    {
        if( key != "Assert" && key != "Temporary" )
        {
            name_list.Push(key)
        }
    }
    return name_list
}

;*******************************************************************************
;
ImeProfilerTickBegin()
{
    global ime_profiler_tick
    name := ProfilerGetCallerName()
    ImeProfilerBeginName(ime_profiler_tick, name)
}

ImeProfilerTickEnd()
{
    local
    global ime_profiler_tick
    name := ProfilerGetCallerName()
    ImeProfilerEndName(ime_profiler_tick, name, "", false)
}

ImeProfilerTickClear()
{
    global ime_profiler_tick := {}
}

ImeProfilerTickGetProfileText()
{
    global ime_profiler_tick
    global ime_profiler

    profiler := ime_profiler_tick["ImeInputterUpdateString_"]

    return Format("({}|{:0.1f}|{}) / ({},{},{}) / ({},{})", profiler[5], profiler[1]/StrLen(ImeInputterStringGetLegacy()), profiler[1]
    , ime_profiler["PinyinSplitterInputStringNormal_", 5]
    , ime_profiler["ImeCandidateUpdateResult_", 5], ime_profiler["SelectorFixupSelectIndex_", 5]
    , ime_profiler["PinyinSqlGetWeight_", 1], ime_profiler["PinyinSqlExecuteGetTable_", 1])
}
