;*******************************************************************************
; [split_index, 0] = select info
;   - 1: select index, work for selector menu, 0 mark not select, should skip this
;   - 2: is lock
;   - lock use:
;       - 3: word value
;       - 4: length
;*******************************************************************************
; Set
SelectorResultSetSelectIndex(ByRef selector_result, split_index, select_index)
{
    local
    selector_result[split_index, 1] := select_index

    profile_text := "`n  - [" split_index "]->[" select_index "] " CallerName()
    ImeProfilerEnd(42, ImeProfilerBegin(42) . profile_text)
}

SelectorResultUnLockWord(ByRef selector_result, split_index)
{
    selector_result[split_index, 2] := false
    selector_result[split_index, 3] := ""
    selector_result[split_index, 4] := 0
}

SelectorResultLockWord(ByRef selector_result, split_index, select_word, word_length)
{
    local
    selector_result[split_index, 2] := true
    selector_result[split_index, 3] := select_word
    selector_result[split_index, 4] := word_length
    profile_text := "`n  - [" split_index "]->[" select_word "," word_length "] "
    ImeProfilerEnd(43, ImeProfilerBegin(43) . profile_text)
}

;*******************************************************************************
; Get
SelectorResultGetSelectIndex(ByRef selector_result, split_index)
{
    return selector_result[split_index, 1] ? selector_result[split_index, 1] : 0
}

SelectorResultIsSelectLock(ByRef selector_result, split_index)
{
    local
    ImeProfilerBegin(44)
    profile_text := "`n  - [" split_index "]->[" selector_result[split_index, 2] "] " CallerName()
    ImeProfilerEnd(44, profile_text)
    return selector_result[split_index, 2] ? true : false
}

SelectorResultGetLockWord(ByRef selector_result, split_index)
{
    return selector_result[split_index, 3]
}

SelectorResultGetLockLength(ByRef selector_result, split_index)
{
    return selector_result[split_index, 4]
}

;*******************************************************************************
;
SelectorResultUnLockFrontWords(ByRef selector_result, split_index)
{
    local
    ; Find if any prev result length include this
    test_length := 0
    loop
    {
        test_index := A_Index
        if( test_index >= split_index ){
            break
        }
        if( SelectorResultIsSelectLock(selector_result, test_index) )
        {
            if( test_length + SelectorResultGetLockLength(selector_result, test_index) >= split_index ){
                SelectorResultUnLockWord(selector_result, test_index)
                break
            }
        }
        else {
            test_length += 1
        }
    }
}

SelectorResultUnLockAfterWords(ByRef selector_result, split_index)
{
    local
    loop % selector_result.Length()
    {
        test_index := A_Index
        if( test_index > split_index )
        {
            SelectorResultUnLockWord(selector_result, test_index)
        }
    }
}
