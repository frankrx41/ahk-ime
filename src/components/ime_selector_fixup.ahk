;*******************************************************************************
;
SelectorCheckTotalWeight(candidate, split_index, left_length, right_length)
{
    left_split_index := split_index
    left_select_index := SelectorFindMaxLengthResultIndex(candidate, left_split_index, left_length)
    left_word_length := CandidateGetWordLength(candidate, left_split_index, left_select_index)
    if( left_word_length != left_length ) {
        return 0
    }
    ; left_word_length := 1
    left_weight  := CandidateGetWeight(candidate, left_split_index, left_select_index) * left_word_length
    left_word  := CandidateGetWord(candidate, left_split_index, left_select_index)

    profile_text := ImeProfilerBegin(46)
    right_split_index := split_index+A_Index
    if( right_split_index > candidate.Length() || right_length == 0 ){
        right_weight := 0
        right_word := ""
        right_word_length := 0
    } else {
        right_select_index := SelectorFindMaxLengthResultIndex(candidate, right_split_index, right_length)
        right_word_length := CandidateGetWordLength(candidate, right_split_index, right_select_index)
        ; right_word_length := 1
        right_weight := CandidateGetWeight(candidate, right_split_index, right_select_index) * right_word_length
        right_word  := CandidateGetWord(candidate, right_split_index, right_select_index)
    }
    ; profile_text .= "`n  - [" left_word "(" left_split_index ") ," right_word "(" right_split_index ") ] " left_weight " + " right_weight " = " left_weight + right_weight
    total_weight := left_weight + right_weight
    return_weight := total_weight / ( left_word_length + right_word_length )
    profile_text .= "`n  - [" left_word left_word_length "," right_word right_word_length "] " left_weight " + " right_weight " = " total_weight " (" Format("{1:0.f}", return_weight) ")"
    ImeProfilerEnd(46, profile_text)

    return return_weight
}

SelectorFindGraceResultIndex(candidate, split_index, max_length)
{
    max_weight := 0
    better_length := max_length
    if( max_length > 2 )
    {
        loop, % max_length
        {
            weight := SelectorCheckTotalWeight(candidate, split_index, A_Index, max_length-A_Index)

            if( weight > max_weight ) {
                max_weight := weight
                better_length := A_Index
            }
        }
    }
    select_index := SelectorFindMaxLengthResultIndex(candidate, split_index, better_length)
    return select_index
}

SelectorFindMaxLengthResultIndex(candidate, split_index, max_length)
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

SelectorFindPossibleMaxLength(ByRef candidate, ByRef selector_result_list, split_index)
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
        max_length := SelectorFindPossibleMaxLength(candidate, selector_result_list, split_index)

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
            if( max_length == candidate.Length() ) {
                select_index := 1
            } else {
                select_index := SelectorFindGraceResultIndex(candidate, split_index, candidate.Length()-split_index+1)
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
