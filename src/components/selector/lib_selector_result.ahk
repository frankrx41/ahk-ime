;*******************************************************************************
; select result
;   - [1]: current select index, work for selector menu, 0 mark no select, should skip this
;   - [2]: lock word (empty means no lock)
;   - [3]: lock length (0 when no lock)
;*******************************************************************************
; Set
SelectorResultSetSelectIndex(ByRef selector_result, select_index)
{
    local
    Assert(selector_result)
    selector_result[1] := select_index
    profile_text := "`n  - " CallerName()
    ImeProfilerDebug(profile_text)
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
    ImeProfilerDebug(profile_text)
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
SelectorResultMake(select_index:=0, lock_word:="", lock_length:=0)
{
    return [select_index, lock_word, lock_length]
}

;*******************************************************************************
;
SelectorGetAvailableSelect(ByRef selector_result, ByRef candidata, new_select, split_index)
{
    new_select := Max(1, Min(candidata[split_index].Length(), new_select))
    if( !CandidateIsDisable(candidata, split_index, new_select) )
    {
        return new_select
    }
    else
    {
        origin_select := SelectorResultGetSelectIndex(selector_result[split_index])
        update_method := origin_select > new_select ? -1 : +1
        loop
        {
            new_select += update_method
            if( new_select == 0 )
            {
                return origin_select
            }
            if( candidata[split_index].Length() == new_select )
            {
                return origin_select
            }
            if( !CandidateIsDisable(candidata, split_index, new_select) )
            {
                return new_select
            }
        }
    }
}
