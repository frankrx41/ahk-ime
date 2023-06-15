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
    global ime_performance_frequency := 0
    DllCall("QueryPerformanceFrequency", "Int64*", ime_performance_frequency)
}

;*******************************************************************************
;
GetPerformanceCounter()
{
    counter := 0
    DllCall("QueryPerformanceCounter", "Int64*", counter)
    return counter
}

GetCounterMilliseconds(counter_after, counter_before)
{
    global ime_performance_frequency
    return (counter_after - counter_before) * 1000 / ime_performance_frequency
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
        Assert(profiler[name, "last_counter"] == 0, "Please call ``ImeProfilerEnd(" name ")`` before call ``ImeProfilerBegin(" name ")``", "msgbox")
        profiler[name, "trace_count"]   += 1
        profiler[name, "last_counter"]  := GetPerformanceCounter()
    } else {
        profiler[name] := []
        profiler[name, "total_time"]    := 0
        profiler[name, "profile_text"]  := ""
        profiler[name, "trace_count"]   := 1
        profiler[name, "last_counter"]  := GetPerformanceCounter()
        profiler[name, "last_call_time"] := 0
    }
}

ImeProfilerEndName(ByRef profiler, name, profile_text, append)
{
    Assert(profiler.HasKey(name) && profiler[name, "last_counter"] != 0, profiler.HasKey(name) "," profiler[name, "last_counter"], "msgbox")
    profiler[name, "last_call_time"] := GetCounterMilliseconds(GetPerformanceCounter(), profiler[name, "last_counter"])
    profiler[name, "total_time"] += profiler[name, "last_call_time"]
    if( profile_text ) {
        profiler[name, "profile_text"] := append ? profiler[name, "profile_text"] "`n  - " : "  - "
        profiler[name, "profile_text"] .= profile_text
    }
    profiler[name, "last_counter"] := 0
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
    name .= "_"
    return ime_profiler_general.HasKey(name)
}

ImeProfilerGeneralGetTotalTick(name)
{
    global ime_profiler_general
    name .= "_"
    Assert(ime_profiler_general.HasKey(name), name, false)
    return Format("{:0.1f}", ime_profiler_general[name, "total_time"])
}

ImeProfilerGeneralGetProfileText(name)
{
    global ime_profiler_general
    name .= "_"
    Assert(ime_profiler_general.HasKey(name), name, false)
    return ime_profiler_general[name, "profile_text"]
}

ImeProfilerGeneralGetCount(name)
{
    global ime_profiler_general
    name .= "_"
    Assert(ime_profiler_general.HasKey(name), name, false)
    return ime_profiler_general[name, "trace_count"]
}

ImeProfilerGeneralGetLastCallTime(name)
{
    global ime_profiler_general
    name .= "_"
    if( ime_profiler_general.HasKey(name) ) {
        return Format("{:0.1f}", ime_profiler_general[name, "last_call_time"])
    }
    else {
        return "NA"
    }
}

;*******************************************************************************
;
ImeProfilerTickGetTotalCallTime(name)
{
    global ime_profiler_tick
    name .= "_"
    Assert(ime_profiler_tick.HasKey(name), name, false)
    return Format("{:0.1f}", ime_profiler_tick[name, "total_time"])
}

ImeProfilerTickGetLastCallTime(name)
{
    global ime_profiler_tick
    name .= "_"
    Assert(ime_profiler_tick.HasKey(name), name, false)
    return Format("{:0.1f}", ime_profiler_tick[name, "last_call_time"])
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
        name_list.Push(key)
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

    profile_text := Format("({}|{:0.1f}|{})"
        , ImeProfilerTickGetLastCallTime("ImeInputterUpdateString")
        , ImeProfilerTickGetTotalCallTime("ImeInputterUpdateString")/StrLen(ImeInputterStringGetLegacy())
        , ImeProfilerTickGetTotalCallTime("ImeInputterUpdateString"))
    profile_text .= Format(" / ({},{},{})"
        , ImeProfilerGeneralGetLastCallTime("PinyinSplitterInputStringNormal")
        , ImeProfilerGeneralGetLastCallTime("ImeCandidateUpdateResult")
        , ImeProfilerGeneralGetLastCallTime("SelectorFixupSelectIndex") )
    profile_text .= Format(" / ({},{})"
        , ImeProfilerGeneralGetLastCallTime("PinyinSqlGetWeight")
        , ImeProfilerGeneralGetLastCallTime("PinyinSqlExecuteGetTable") )

    profile_text .= Format(" / ({},{})"
        , ImeProfilerGeneralGetLastCallTime("PinyinTranslateFindResult")
        , ImeProfilerGeneralGetLastCallTime("PinyinTranslatorInsertResult") )

    profile_text .= Format(" / ({},{})"
        , ImeProfilerGeneralGetLastCallTime("TranslatorResultListFilterByRadical")
        , ImeProfilerGeneralGetLastCallTime("RadicalCheckMatchLevel") )

    return profile_text
}
