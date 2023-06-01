;*******************************************************************************
; Move caret
; -1 <- | -> +1
InputterCaretMove(caret_pos, dir, input_string)
{
    input_string_len := StrLen(input_string)
    caret_pos += dir

    if( caret_pos < 0 )
    {
        caret_pos := input_string_len
    }
    else
    if( caret_pos > input_string_len )
    {
        caret_pos := 0
    }
    return caret_pos
}

; move to initials
InputterCaretMoveSmartRight(caret_pos, input_string, ByRef splitted_list)
{

    input_string_len := StrLen(input_string)

    loop_count := 1
    current_pos := caret_pos
    loop, % loop_count
    {
        last_pos := current_pos
        ; loop
        if( current_pos == input_string_len )
        {
            current_pos := 0
        }

        ; update word index
        if( last_pos == current_pos )
        {
            current_start_pos := SplitterResultListGetCurrentWordPos(splitted_list, current_pos)
            if( current_start_pos == current_pos && InStr("zcs", SubStr(input_string, current_start_pos+1, 1)) )
            {
                if( SubStr(input_string, current_start_pos+2, 1) == "h" )
                {
                    current_pos += 2
                } else {
                    current_pos += 1
                }
            }
            else
            {
                right_pos := SplitterResultListGetRightWordPos(splitted_list, current_pos)
                current_pos := right_pos
            }
        }
    }
    return current_pos
}

; graceful: take a white space move as a step
InputterCaretMoveByWord(caret_pos, dir, graceful, input_string, ByRef splitted_list)
{
    move_count := dir > 0 ? dir : (-1 * dir)
    if( dir > 0 ){
        if( caret_pos == StrLen(input_string) ){
            word_pos := 0
        }
        else {
            word_pos := caret_pos
            index := 0
            loop
            {
                if( index == move_count ) {
                    break
                }
                index += 1
                begin_pos := word_pos
                word_pos := SplitterResultListGetRightWordPos(splitted_list, word_pos)
                if( graceful && SubStr(input_string, word_pos, 1) == " " && begin_pos+1 != word_pos ) {
                    word_pos := word_pos-1
                }
            }
        }
    } else {
        if( caret_pos == 0 ){
            word_pos := StrLen(input_string)
        } else {
            word_pos := caret_pos
            index := 0
            loop
            {
                if( index == move_count ) {
                    break
                }
                if( graceful && SubStr(input_string, word_pos, 1) == " " ) {
                    index += 1
                    word_pos := word_pos-1
                } else {
                    index += 1
                    word_pos := SplitterResultListGetLeftWordPos(splitted_list, word_pos)
                }
            }
        }
    }
    return word_pos
}

;*******************************************************************************
; Move to
InputterCaretMoveToChar(caret_pos, char, input_string, back_to_front, try_rollback:=true)
{
    local

    loop, 2
    {
        if( A_Index == 1 )
        {
            if( back_to_front ) {
                start_index := caret_pos - StrLen(input_string)
            } else {
                start_index := caret_pos + 2
            }
        }
        else if( try_rollback )
        {
            if( back_to_front ) {
                start_index := 0
            } else {
                start_index := 1
            }
        }
        index := InStr(input_string, char, false, start_index)
        if( index != 0 ) {
            caret_pos := index
            break
        }
    }
    return caret_pos
}

InputterCaretMoveToIndex(caret_pos, index, ByRef splitted_list)
{
    if( splitted_list.Length() >= index )
    {
        caret_pos := SplitterResultGetStartPos(splitted_list[index])
    }
    else
    {
        caret_pos := SplitterResultGetEndPos(splitted_list[index-1])
    }
    return caret_pos
}
