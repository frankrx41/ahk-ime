;*******************************************************************************
; This file ONLY used for debug
;
; Please stop track this file
; You can use the following command:
;   - To track: `git update-index --no-skip-worktree src\utils\ime_debug.ahk`
;   - To skip:  `git update-index --skip-worktree src\utils\ime_debug.ahk`
;*******************************************************************************
; Static
ImeDebugTipAppend(ByRef debug_tip, index, max_length := 100)
{
    if( ImeProfilerGetCount(index) >= 1 ){
        debug_tip .= "`n" . index . "*" ImeProfilerGetCount(index) ":"
        debug_tip .= "(" ImeProfilerGetTotalTick(index) ") "
        debug_info := ImeProfilerGetDebugInfo(index)
        if( StrLen(debug_info) > max_length ){
            debug_info := SubStr(debug_info, 1, max_length)
            debug_info .= "..."
        }
        if( index == 1 ) {
            debug_tip .= debug_info
        } else {
            ; Show full info
            if( ImeDebugGet() == 2 ) {
                debug_tip .= debug_info
            }
        }
    }
}

ImeDebugGetDisplayText()
{
    local debug_tip := ""
    if( !ImeDebugGet() )
    {
        return debug_tip
    }

    ; Comment out the debug info you don't want
    ; If you want add new debug info, do follow:
    ; ```
    ;   profile_text := ImeProfilerBegin(1)
    ;   ImeProfilerEnd(1, profile_text)
    ; ```
    ; See ime_profiler.ahk for detail.
    ImeDebugTipAppend(debug_tip, 10)
    ImeDebugTipAppend(debug_tip, 11)        ; PinyinSplitterInputString
    ImeDebugTipAppend(debug_tip, 12)        ; ImeInputterCallTranslator
    ImeDebugTipAppend(debug_tip, 13)        ; PinyinSplitterCheckDBWeight
    ImeDebugTipAppend(debug_tip, 14)

    ImeDebugTipAppend(debug_tip, 15, 200)   ; PinyinSqlGetResult - sql
    ImeDebugTipAppend(debug_tip, 16, 200)   ; PinyinSqlGetResult - result
    ImeDebugTipAppend(debug_tip, 17)        ; TranslatorHistoryUpdateKey
    ImeDebugTipAppend(debug_tip, 18)
    ImeDebugTipAppend(debug_tip, 19)

    ImeDebugTipAppend(debug_tip, 20)        ; PinyinGetTranslateResult
    ImeDebugTipAppend(debug_tip, 21, 200)   ; PinyinTranslatorInsertResult
    ImeDebugTipAppend(debug_tip, 22)        ; PinyinTranslatorInsertCombineWord
    ImeDebugTipAppend(debug_tip, 23)        ; PinyinTranslatorInsertSimpleSpell
    ImeDebugTipAppend(debug_tip, 24)

    ImeDebugTipAppend(debug_tip, 25)
    ImeDebugTipAppend(debug_tip, 26)
    ImeDebugTipAppend(debug_tip, 27)
    ImeDebugTipAppend(debug_tip, 28)
    ImeDebugTipAppend(debug_tip, 29)

    ImeDebugTipAppend(debug_tip, 30)        ; ImeCandidateUpdateResult
    ImeDebugTipAppend(debug_tip, 31, 200)   ; CandidateResultListFilterResults
    ImeDebugTipAppend(debug_tip, 32)        ; CandidateResultListFindIndex
    ImeDebugTipAppend(debug_tip, 33)
    ImeDebugTipAppend(debug_tip, 34)

    ImeDebugTipAppend(debug_tip, 35)        ; TranslatorResultListFilterZeroWeight
    ImeDebugTipAppend(debug_tip, 36)        ; TranslatorResultListFilterByRadical
    ImeDebugTipAppend(debug_tip, 37)        ; TranslatorResultListFilterSingleWord
    ImeDebugTipAppend(debug_tip, 38)
    ImeDebugTipAppend(debug_tip, 39)        ; TranslatorResultListUniquify

    ImeDebugTipAppend(debug_tip, 40, 200)   ; SelectorFixupSelectIndex
    ImeDebugTipAppend(debug_tip, 41)        ; ImeSelectorApplyCaretSelectIndex
    ImeDebugTipAppend(debug_tip, 42, 200)   ; SelectorResultSetSelectIndex
    ImeDebugTipAppend(debug_tip, 43)        ; SelectorResultLockWord
    ImeDebugTipAppend(debug_tip, 44)

    ImeDebugTipAppend(debug_tip, 45)        ; SelectorFindPossibleMaxLength
    ImeDebugTipAppend(debug_tip, 46, 200)   ; SelectorFindGraceResultIndex
    ImeDebugTipAppend(debug_tip, 47)        ; SelectorFindGraceResultIndex
    ImeDebugTipAppend(debug_tip, 48)
    ImeDebugTipAppend(debug_tip, 49)

    ImeDebugTipAppend(debug_tip, 1)         ; temp
    ; ImeDebugTipAppend(debug_tip, 8)         ; tick
    debug_tip .= "`n----------------"
    ImeDebugTipAppend(debug_tip, 4, 200)   ; assert info

    return debug_tip
}
