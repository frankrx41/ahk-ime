;*******************************************************************************
; This file ONLY used for debug
;
; Please stop track this file
; You can use the following command:
;   - To stop:  `git update-index --no-skip-worktree ime_debug.ahk`
;   - To track: `git update-index --skip-worktree ime_debug.ahk`
;*******************************************************************************
; Static
ImeDebugTipAppend(ByRef debug_tip, index, max_length := 100)
{
    if( ImeProfilerGetCount(index) >= 1 ){
        debug_tip .= "`n" . index . "*" ImeProfilerGetCount(index) ":"
        debug_tip .= "(" ImeProfilerGetTotalTick(index) ") "
        debug_info := ImeProfilerGetDebugInfo(index)
        if( StrLen(debug_info) > max_length ){
            SubStr(debug_info, 1, max_length)
            debug_info .= "..."
        }
        debug_tip .= debug_info
    }
}

ImeDebugGetDisplayText()
{
    local debug_tip := ""
    if( !IsDebugVersion() )
    {
        return debug_tip
    }

    ; Comment out the debug info you don't want
    ; If you want add new debug info, do follow:
    ; ```
    ;   ImeProfilerBegin(1)
    ;   ImeProfilerEnd(1, "Your debug info")
    ; ```
    ; See ime_profiler.ahk for detail.
    ImeDebugTipAppend(debug_tip, 11)    ; PinyinSplitterInputString
    ImeDebugTipAppend(debug_tip, 12)    ; ImeInputterCallTranslator
    ImeDebugTipAppend(debug_tip, 15, 2000)  ; PinyinSqlGetResult - sql
    ImeDebugTipAppend(debug_tip, 16, 2000)  ; PinyinSqlGetResult - result
    ImeDebugTipAppend(debug_tip, 20)    ; PinyinGetTranslateResult
    ImeDebugTipAppend(debug_tip, 22)    ; PinyinTranslatorInsertSimpleSpell
    ImeDebugTipAppend(debug_tip, 25)    ; PinyinResultFilterZeroWeight
    ImeDebugTipAppend(debug_tip, 26)    ; TranslatorResultFilterByRadical
    ImeDebugTipAppend(debug_tip, 27)    ; PinyinResultFilterSingleWord
    ImeDebugTipAppend(debug_tip, 28)    ; PinyinResultUniquify
    ImeDebugTipAppend(debug_tip, 30)    ; ImeTranslatorUpdateResult
    ImeDebugTipAppend(debug_tip, 31, 2000)  ; ImeTranslatorFilterResults
    ImeDebugTipAppend(debug_tip, 32, 2000)  ; ImeTranslatorFixupSelectIndex
    ImeDebugTipAppend(debug_tip, 41)    ; ImeSelectorApplyCaretSelectIndex
    ImeDebugTipAppend(debug_tip, 42, 2000)  ; ImeSelectorSetSelectIndex
    ImeDebugTipAppend(debug_tip, 43)    ; ImeSelectorLockWord
    ImeDebugTipAppend(debug_tip, 44)    ; ImeSelectorIsSelectLock
    ImeDebugTipAppend(debug_tip, 1)     ; temp
    ImeDebugTipAppend(debug_tip, 2)     ; tick
    debug_tip .= "`n----------------"
    ImeDebugTipAppend(debug_tip, 4, 2000)   ; assert info

    return debug_tip
}
