;*******************************************************************************
;
TranslatorFindMaxLengthResultIndex(split_index, max_length)
{
    local
    loop % ImeTranslatorResultListGetListLength(split_index)
    {
        test_len := ImeTranslatorResultListGetWordLength(split_index, A_Index)
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
    if( ImeSelectorIsSelectLock(split_index) )
    {
        max_length := ImeTranslatorResultListGetWordLength(split_index, 1)
    }
    else
    {
        max_length := 1
        loop
        {
            check_index := split_index + A_Index
            if( check_index > ImeTranslatorResultListGetLength() ){
                break
            }
            if( ImeSelectorIsSelectLock(check_index) ) {
                break
            }
            max_length += 1
        }
    }
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
    loop % ImeTranslatorResultListGetLength()
    {
        split_index := A_Index

        origin_select_index := ImeSelectorGetSelectIndex(split_index)
        select_index := !origin_select_index ? 0 : origin_select_index

        if( select_index ) {
            select_word_length := ImeTranslatorResultListGetWordLength(split_index, select_index)
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
            select_index := ImeTranslatorResultFindIndex(split_index, lock_word, max_length)
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
            select_word_length := ImeTranslatorResultListGetWordLength(split_index, select_index)
            skip_word_count := select_word_length-1
            profile_text .= "skip: " skip_word_count " "
        }
    }
    ImeProfilerEnd(40, profile_text)
    Assert(skip_word_count == 0, skip_word_count)
}
