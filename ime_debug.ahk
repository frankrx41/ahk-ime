ImeDebugTipAdd(ByRef debug_tip, index, max_length := 100)
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
    ImeDebugTipAdd(debug_tip, 11)    ; PinyinSplitInputString
    ImeDebugTipAdd(debug_tip, 12)    ; ImeInputterUpdateString
    ImeDebugTipAdd(debug_tip, 14, 0) ; PinyinHistoryHasKey
    ImeDebugTipAdd(debug_tip, 15, 2000)  ; PinyinSqlGetResult - sql
    ImeDebugTipAdd(debug_tip, 16, 2000)  ; PinyinSqlGetResult - result
    ImeDebugTipAdd(debug_tip, 20)    ; PinyinGetTranslateResult
    ImeDebugTipAdd(debug_tip, 22)    ; PinyinResultInsertSimpleSpell
    ImeDebugTipAdd(debug_tip, 25)    ; PinyinResultFilterZeroWeight
    ImeDebugTipAdd(debug_tip, 26)    ; PinyinResultFilterByRadical
    ImeDebugTipAdd(debug_tip, 27)    ; PinyinResultFilterSingleWord
    ImeDebugTipAdd(debug_tip, 28)    ; PinyinResultUniquify
    ImeDebugTipAdd(debug_tip, 30)    ; ImeTranslatorUpdateResult
    ImeDebugTipAdd(debug_tip, 31, 2000)  ; ImeTranslatorFilterResults
    ImeDebugTipAdd(debug_tip, 32, 2000)  ; ImeTranslatorFixupSelectIndex
    ImeDebugTipAdd(debug_tip, 41)    ; ImeSelectorApplyCaretSelectIndex
    ImeDebugTipAdd(debug_tip, 42, 2000)  ; ImeSelectorApplyCaretSelectIndex
    ImeDebugTipAdd(debug_tip, 1)     ; temp
    ImeDebugTipAdd(debug_tip, 2)     ; tick
    ImeDebugTipAdd(debug_tip, 4, 2000)   ; assert info
    return debug_tip
}
