;*******************************************************************************
; select result
;   - 1: current select index, work for selector menu, 0 mark no select, should skip this
;   - 2: lock word (empty means no lock)
;   - 3: lock length (0 when no lock)
;*******************************************************************************
; Set
SelectorResultSetSelectIndex(ByRef selector_result, select_index)
{
    local
    Assert(selector_result)
    selector_result[1] := select_index
    profile_text := "`n  - " CallerName()
    ImeProfilerEnd(42, ImeProfilerBegin(42) . profile_text)
}

SelectorResultUnLockWord(ByRef selector_result)
{
    Assert(selector_result)
    selector_result[2] := ""
    selector_result[3] := 0
}

SelectorResultLockWord(ByRef selector_result, select_word, word_length)
{
    local
    Assert(selector_result)
    selector_result[2] := select_word
    selector_result[3] := word_length
    profile_text := "`n  ->[" selector_result[1] "," select_word "," word_length "] "
    ImeProfilerEnd(43, ImeProfilerBegin(43) . profile_text)
}

;*******************************************************************************
; Get
SelectorResultGetSelectIndex(ByRef selector_result)
{
    return selector_result[1] ? selector_result[1] : 0
}

SelectorResultIsSelectLock(ByRef selector_result)
{
    return selector_result[2] ? true : false
}

SelectorResultGetLockWord(ByRef selector_result)
{
    return selector_result[2]
}

SelectorResultGetLockLength(ByRef selector_result)
{
    return selector_result[3]
}

;*******************************************************************************
;
SelectorResultUnLockFrontWords(ByRef selector_result_list, split_index)
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
        if( SelectorResultIsSelectLock(selector_result_list[test_index]) )
        {
            if( test_length + SelectorResultGetLockLength(selector_result_list[test_index]) >= split_index ){
                SelectorResultUnLockWord(selector_result_list[test_index])
                break
            }
        }
        else {
            test_length += 1
        }
    }
}

SelectorResultUnLockAfterWords(ByRef selector_result_list, split_index)
{
    local
    loop % selector_result_list.Length()
    {
        test_index := A_Index
        if( test_index > split_index )
        {
            SelectorResultUnLockWord(selector_result_list[test_index])
        }
    }
}
