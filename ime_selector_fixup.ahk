;*******************************************************************************
;
TranslatorFindMaxLengthResultIndex(split_index, max_length)
{
    local
    loop % ImeCandidateGetListLength(split_index)
    {
        test_len := ImeCandidateGetWordLength(split_index, A_Index)
        if( test_len <= max_length )
        {
            return A_Index
        }
    }
    return 0
}

TranslatorFindPossibleMaxLength(split_index)
{
    local
    ; `max_length` = this word until next unlock word
    profile_text := ImeProfilerBegin(45)
    loop_cnt := 0
    if( ImeSelectorIsSelectLock(split_index) )
    {
        max_length := ImeCandidateGetWordLength(split_index, ImeSelectorGetSelectIndex(split_index))
    }
    else
    {
        max_length := 1
        loop
        {
            loop_cnt += 1
            check_index := split_index + A_Index
            if( check_index > ImeCandidateGetLength() ){
                break
            }
            if( ImeSelectorIsSelectLock(check_index) ) {
                break
            }
            max_length += 1
        }
    }

    if( max_length == ImeCandidateGetLength() ){
        Assert(split_index == 1)
        max_length := ImeCandidateGetWordLength(split_index, 1)
    }

    profile_text .= "`n  - [" split_index "] loop: " loop_cnt " -> " max_length
    ImeProfilerEnd(45, profile_text)
    return max_length
}

;*******************************************************************************
;
ImeSelectorFixupSelectIndex()
{
    local
    profile_text := ""
    ImeProfilerBegin(40)
    skip_word_count := 0
    loop % ImeCandidateGetLength()
    {
        split_index := A_Index

        origin_select_index := ImeSelectorGetSelectIndex(split_index)
        select_index := !origin_select_index ? 0 : origin_select_index

        if( select_index ) {
            select_word_length := ImeCandidateGetWordLength(split_index, select_index)
        } else {
            select_word_length := 0
        }
        select_is_lock := ImeSelectorIsSelectLock(split_index)

        ; `max_length` = this word until next unlock word
        max_length := TranslatorFindPossibleMaxLength(split_index)

        profile_text .= "`n  - [" split_index "] "
        profile_text .= "skip: " skip_word_count ", lock: " select_is_lock ", max_len: " max_length " "

        if( skip_word_count )
        {
            Assert( !ImeSelectorIsSelectLock(split_index) )
            select_index := 0
            skip_word_count -= 1
        }
        else
        if( select_is_lock )
        {
            lock_word := ImeSelectorGetLockWord(split_index)
            ; TODO: use `lock_length`
            lock_length := ImeSelectorGetLockLength(split_index)
            Assert( max_length <= lock_length )
            select_index := ImeCandidateFindIndex(split_index, lock_word, max_length)
            Assert(select_index, "[" split_index "]" lock_length "," select_index "," lock_word "," max_length)
        }
        else
        {
            ; Find a result the no longer than `max_length`
            if( select_index == 0 || select_word_length > max_length )
            {
                select_index := TranslatorFindMaxLengthResultIndex(split_index, max_length)
            }
        }

        if( origin_select_index != select_index )
        {
            ImeSelectorSetSelectIndex(split_index, select_index)
        }

        profile_text .= "[" origin_select_index "]->[" select_index "] "
        if( select_index )
        {
            select_word_length := ImeCandidateGetWordLength(split_index, select_index)
            skip_word_count := select_word_length-1
            profile_text .= "skip: " skip_word_count " "
        }
    }
    ImeProfilerEnd(40, profile_text)
    Assert(skip_word_count == 0, skip_word_count)
}
