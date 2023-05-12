;*******************************************************************************
;
TranslatorFindMaxLengthResultIndex(candidate, split_index, max_length)
{
    local
    loop % CandidateGetListLength(candidate, split_index)
    {
        test_len := CandidateGetWordLength(candidate, split_index, A_Index)
        if( test_len <= max_length )
        {
            return A_Index
        }
    }
    return 0
}

TranslatorFindPossibleMaxLength(ByRef candidate, ByRef selector_result_list, split_index)
{
    local
    ; `max_length` = this word until next unlock word
    profile_text := ImeProfilerBegin(45)
    loop_cnt := 0
    if( SelectorResultIsSelectLock(selector_result_list[split_index]) )
    {
        max_length := CandidateGetWordLength(candidate, split_index, SelectorResultGetSelectIndex(selector_result_list[split_index]))
    }
    else
    {
        max_length := 1
        loop
        {
            loop_cnt += 1
            check_index := split_index + A_Index
            if( check_index > candidate.Length() ){
                break
            }
            if( SelectorResultIsSelectLock(selector_result_list[check_index]) ) {
                break
            }
            max_length += 1
        }
    }

    if( max_length == candidate.Length() ){
        Assert(split_index == 1)
        max_length := CandidateGetWordLength(candidate, split_index, 1)
    }

    profile_text .= "`n  - [" split_index "] loop: " loop_cnt " -> " max_length
    ImeProfilerEnd(45, profile_text)
    return max_length
}

;*******************************************************************************
;
SelectorFixupSelectIndex(candidate, const_selector_result_list)
{
    local
    profile_text := ""
    ImeProfilerBegin(40)
    skip_word_count := 0
    selector_result_list := CopyObj(const_selector_result_list)
    loop % candidate.Length()
    {
        split_index := A_Index
        if( !selector_result_list[split_index] ){
            selector_result_list[split_index] := []
        }

        origin_select_index := SelectorResultGetSelectIndex(selector_result_list[split_index])
        select_index := !origin_select_index ? 0 : origin_select_index

        if( select_index ) {
            select_word_length := CandidateGetWordLength(candidate, split_index, select_index)
        } else {
            select_word_length := 0
        }
        select_is_lock := SelectorResultIsSelectLock(selector_result_list[split_index])

        ; `max_length` = this word until next unlock word
        max_length := TranslatorFindPossibleMaxLength(candidate, selector_result_list, split_index)

        profile_text .= "`n  - [" split_index "] "
        profile_text .= "skip: " skip_word_count ", lock: " select_is_lock ", max_len: " max_length " "

        if( skip_word_count )
        {
            Assert( !SelectorResultIsSelectLock(selector_result_list[split_index]) )
            select_index := 0
            skip_word_count -= 1
        }
        else
        if( select_is_lock )
        {
            lock_word := SelectorResultGetLockWord(selector_result_list[split_index])
            ; TODO: use `lock_length`
            lock_length := SelectorResultGetLockLength(selector_result_list[split_index])
            Assert( max_length <= lock_length )
            select_index := CandidateFindIndex(candidate, split_index, lock_word, max_length)
            Assert(select_index, "[" split_index "]" lock_length "," select_index "," lock_word "," max_length)
        }
        else
        {
            ; Find a result the no longer than `max_length`
            if( select_index == 0 || select_word_length > max_length )
            {
                select_index := TranslatorFindMaxLengthResultIndex(candidate, split_index, max_length)
            }
        }

        if( origin_select_index != select_index )
        {
            SelectorResultSetSelectIndex(selector_result_list[split_index], select_index)
        }

        profile_text .= "[" origin_select_index "]->[" select_index "] "
        if( select_index )
        {
            select_word_length := CandidateGetWordLength(candidate, split_index, select_index)
            skip_word_count := select_word_length-1
            profile_text .= "skip: " skip_word_count " "
        }
    }
    ImeProfilerEnd(40, profile_text)
    Assert(skip_word_count == 0, skip_word_count)

    return selector_result_list
}
