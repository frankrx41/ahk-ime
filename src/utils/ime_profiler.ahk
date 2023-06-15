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
; * `ImeProfilerDataClear()` will clear all profile, this function will be call every
;   time you type a new char or you delete any chars.
;*******************************************************************************
ImeProfilerInitialize()
{
    ImeProfilerGeneralClear()
    ImeProfilerTickClear()
}

ImeProfilerGeneralClear()
{
    global ime_profiler_general := {}
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
        Assert(profiler[name, 4] == 0, "Please call ``ImeProfilerEnd(" name ")`` before call ``ImeProfilerBegin(" name ")``", "msgbox")
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
    Assert(profiler.HasKey(name) && profiler[name, 4] != 0, "Please call ``ImeProfilerBegin(" name ")`` before call ``ImeProfilerEnd(" name ")``", "msgbox")
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
    global ime_profiler_general
    name := ProfilerGetCallerName()
    ImeProfilerBeginName(ime_profiler_general, name)
}

ImeProfilerEnd(profile_text:="", append:=true)
{
    local
    global ime_profiler_general
    name := ProfilerGetCallerName()
    ImeProfilerEndName(ime_profiler_general, name, profile_text, append)
}

ImeProfilerDebug(profile_text, append:=true)
{
    local
    global ime_profiler_general
    name := ProfilerGetCallerName()
    ImeProfilerBeginName(ime_profiler_general, name)
    ImeProfilerEndName(ime_profiler_general, name, profile_text, append)
}

ImeProfilerTemp(profile_text, append:=true)
{
    local
    global ime_profiler_general
    name := "Temporary_"
    ImeProfilerBeginName(ime_profiler_general, name)
    ImeProfilerEndName(ime_profiler_general, name, profile_text, append)
}

ImeProfilerFunc(func_name)
{
    local
    global ime_profiler_general
    name := ProfilerGetCallerName() . func_name
    ImeProfilerBeginName(ime_profiler_general, name)
    last_tick := A_TickCount
    Func(func_name).Call()
    profile_text := func_name " (" A_TickCount - last_tick ")"
    ImeProfilerEndName(ime_profiler_general, name, profile_text, true)
}

;*******************************************************************************
; Use for print
ImeProfilerGeneralHasKey(name)
{
    global ime_profiler_general
    return ime_profiler_general.HasKey(name)
}

ImeProfilerGeneralGetTotalTick(name)
{
    global ime_profiler_general
    Assert(ime_profiler_general.HasKey(name), name, false)
    return ime_profiler_general[name, 1]
}

ImeProfilerGeneralGetProfileText(name)
{
    global ime_profiler_general
    Assert(ime_profiler_general.HasKey(name), name, false)
    return ime_profiler_general[name, 2]
}

ImeProfilerGeneralGetCount(name)
{
    global ime_profiler_general
    Assert(ime_profiler_general.HasKey(name), name, false)
    return ime_profiler_general[name, 3]
}

;*******************************************************************************
;
ImeProfilerGeneralGetAllNameList()
{
    local
    global ime_profiler_general
    name_list := []
    for key, value in ime_profiler_general
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
    global ime_profiler_general

    profiler := ime_profiler_tick["ImeInputterUpdateString_"]
    profile_text := Format("({}|{:0.1f}|{})"
        , profiler[5]
        , profiler[1]/StrLen(ImeInputterStringGetLegacy())
        , profiler[1])
    profile_text .= Format(" / ({},{},{})"
        , ime_profiler_general["PinyinSplitterInputStringNormal_", 5]
        , ime_profiler_general["ImeCandidateUpdateResult_", 5]
        , ime_profiler_general["SelectorFixupSelectIndex_", 5] )
    profile_text .= Format(" / ({},{})"
        , ime_profiler_general["PinyinSqlGetWeight_", 1]
        , ime_profiler_general["PinyinSqlExecuteGetTable_", 1] )

    return profile_text
}
