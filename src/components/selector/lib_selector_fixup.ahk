SelectorFindPossibleMaxLength(ByRef candidate, ByRef splitted_list, ByRef selector_result_list, split_index)
{
    local
    ; `max_length` = this word until next unlock word
    ImeProfilerBegin()
    loop_cnt := 0
    if( SelectorResultIsSelectLock(selector_result_list[split_index]) )
    {
        max_length := CandidateGetWordLength(candidate, split_index, SelectorResultGetSelectIndex(selector_result_list[split_index]))
    }
    else
    {
        max_length := 1
        hope_length_1st := SplitterResultGetHopeLength(splitted_list[split_index])
        hope_length_2rd := ""
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
            if( !SplitterResultNeedTranslate(splitted_list[check_index]) ) {
                break
            }
            if( hope_length_1st == A_Index ){
                hope_length_2rd := SplitterResultGetHopeLength(splitted_list[check_index]) + hope_length_1st
            }
            if( hope_length_2rd == A_Index ){
                break
            }
            max_length += 1
        }
    }

    if( max_length == candidate.Length() ){
        Assert(split_index == 1, "", false)
        ; max_length := CandidateGetWordLength(candidate, split_index, 1)
    }

    profile_text := "[" split_index "] loop: " loop_cnt " -> " max_length
    ImeProfilerEnd(profile_text)
    return max_length
}

;*******************************************************************************
;
SelectorFixupSelectIndex(candidate, const_selector_result_list)
{
    local
    profile_text := ""
    ImeProfilerBegin()
    skip_word_count := 0
    selector_result_list := CopyObj(const_selector_result_list)
    splitted_list := CandidateGetSplittedList(candidate)
    loop % candidate.Length()
    {
        split_index := A_Index
        if( !selector_result_list[split_index] ){
            if( split_index == candidate.Length() ) {
                selector_result_list[split_index] := SelectorResultMake(0)
            } else {
                selector_result_list[split_index] := SelectorResultMake(1)
            }
        }

        origin_select_index := SelectorResultGetSelectIndex(selector_result_list[split_index])
        select_index := !origin_select_index ? 0 : origin_select_index
        if( select_index ) {
            select_word_length := CandidateGetWordLength(candidate, split_index, select_index)
        } else {
            select_word_length := 0
        }
        select_is_lock := SelectorResultIsSelectLock(selector_result_list[split_index])

        profile_text .= "[" split_index "] "
        if( split_index == candidate.Length() )
        {
            Assert(skip_word_count == 0, SplitterResultListGetDebugText(splitted_list) "`n" skip_word_count, false)

            last_split_index := split_index - 1
            if( select_word_length != 0 )
            {
                profile_text .= "(" select_word_length ") " last_split_index
                index := 0
                loop, % selector_result_list.Length() - 1
                {
                    check_select_index := SelectorResultGetSelectIndex(selector_result_list[A_Index])
                    if( check_select_index ) {
                        check_length := CandidateGetWordLength(candidate, A_Index, check_select_index)
                        profile_text .= "`n    - " index "+" check_length 
                        if( check_length + index > last_split_index - select_word_length){
                            check_index := index
                            max_length := last_split_index - select_word_length - index
                            profile_text .= " (" max_length ")"
                            loop
                            {
                                check_index += 1
                                if( check_index > last_split_index ) {
                                    break
                                }
                                if( max_length > 0 ) {
                                    find_select_index := CandidateFindMaxLengthSelectIndex(candidate, check_index, max_length)
                                } else {
                                    find_select_index := 0
                                }
                                profile_text .= " [" check_index "]->[" find_select_index "]"
                                SelectorResultSetSelectIndex(selector_result_list[check_index], find_select_index)
                                SelectorResultUnLockWord(selector_result_list[check_index])
                                max_length -= CandidateGetWordLength(candidate, check_index, find_select_index)
                                if( max_length <= 0) {
                                    break
                                }
                            }
                        }
                        index += check_length
                    }
                }
            }
        }
        else
        {
            ; `max_length` = this word until next unlock word
            max_length := SelectorFindPossibleMaxLength(candidate, splitted_list, selector_result_list, split_index)

            profile_text .= "skip: " skip_word_count ", lock: " select_is_lock ", max_len: " max_length " "

            if( skip_word_count )
            {
                Assert( !SelectorResultIsSelectLock(selector_result_list[split_index]), "", false )
                select_index := 0
                skip_word_count -= 1
            }
            else
            if( select_is_lock )
            {
                lock_word := SelectorResultGetLockWord(selector_result_list[split_index])
                ; TODO: use `lock_length`
                lock_length := SelectorResultGetLockLength(selector_result_list[split_index])
                Assert( max_length <= lock_length, "", false )
                select_index := CandidateFindWordSelectIndex(candidate, split_index, lock_word)
                Assert(select_index, "[" split_index "]" lock_length "," select_index "," lock_word "," max_length, false)
            }
            else
            if( !SplitterResultNeedTranslate(splitted_list[split_index]) )
            {
                select_index := 1
            }
            else
            {
                select_index := 0
                check_length := split_index+max_length-1
                if( candidate.Length() == check_length || !SplitterResultNeedTranslate(splitted_list[split_index+max_length]) )
                {
                    if( max_length == 1 ){
                        select_index := CandidateFindMaxLengthSelectIndex(candidate, split_index, 1)
                    }
                    else
                    {
                        if( CandidateGetWordLength(candidate, split_index, 1) == max_length ){
                            select_index := 1
                        } else {
                            select_index := CandidateFindMaxLengthSelectIndex(candidate, split_index, max_length)
                        }
                    }
                }

                if( select_index == 0 || (select_index && CandidateGetWordLength(candidate, split_index, select_index) != max_length) )
                {
                    select_index := SelectorFindGraceResultIndex(candidate, split_index, max_length)
                }
            }
            profile_text .= "[" origin_select_index "]->[" select_index "] "

            if( select_index )
            {
                select_index := SelectorGetAvailableSelect(selector_result_list, candidate, select_index, split_index)
                select_word_length := CandidateGetWordLength(candidate, split_index, select_index)
                Assert(select_word_length != "", "[" split_index ", " select_index "]: (" CandidateGetWord(candidate, split_index, select_index) ", " CandidateGetLegacyPinyin(candidate, split_index, select_index) ")", false)
                skip_word_count := select_word_length-1
                profile_text .= "skip: " skip_word_count " "
            }
        }

        if( origin_select_index != select_index )
        {
            SelectorResultSetSelectIndex(selector_result_list[split_index], select_index)
        }
    }

    ImeProfilerEnd(profile_text)

    return selector_result_list
}
