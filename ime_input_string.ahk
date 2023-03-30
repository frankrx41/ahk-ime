ImeInputStringClearPrevSplitted(input_string, split_indexs, ByRef caret_pos)
{
    check_index := caret_pos

    if( check_index != 0 )
    {
        left_pos := ImeInputStringGetLeftWordPos(check_index, split_indexs)
        input_string := SubStr(input_string, 1, left_pos) . SubStr(input_string, caret_pos+1)
        caret_pos := left_pos
    }
    return input_string
}

ImeInputStringGetPosSplitIndex(caret_pos, split_indexs)
{
    if( split_indexs.Length() >= 1)
    {
        if( split_indexs[split_indexs.Length()] == caret_pos )
        {
            return split_indexs.Length()
        }
        loop % split_indexs.Length()
        {
            if( split_indexs[A_Index] > caret_pos ){
                return A_Index
            }
        }
        global ime_input_string
        Assert(false, ime_input_string "," caret_pos)
    }
}

ImeInputStringGetLeftWordPos(start_index, split_indexs)
{
    local
    if( start_index == 0 ){
        return 0
    }
    last_index := 0
    loop, % split_indexs.Length()
    {
        split_index := split_indexs[A_Index]
        if( split_index >= start_index ){
            break
        }
        last_index := split_index
    }
    return last_index
}

ImeInputStringGetRightWordPos(start_index, split_indexs)
{
    local
    last_index := start_index
    loop, % split_indexs.Length()
    {
        split_index := split_indexs[A_Index]
        if( split_index > start_index ){
            last_index := split_index
            break
        }
    }
    return last_index
}
