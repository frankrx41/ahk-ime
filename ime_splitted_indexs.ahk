; Action about splitted indexs
SplittedIndexsGetPosIndex(splitted_indexs, caret_pos)
{
    if( splitted_indexs.Length() >= 1)
    {
        if( splitted_indexs[splitted_indexs.Length()] == caret_pos )
        {
            return splitted_indexs.Length()
        }
        loop % splitted_indexs.Length()
        {
            if( splitted_indexs[A_Index] > caret_pos ){
                return A_Index
            }
        }
        Assert(false, splitted_indexs.Length() "," caret_pos)
    }
    return 1
}

SplittedIndexsGetLeftWordPos(splitted_indexs, start_pos)
{
    local
    if( start_pos == 0 ){
        return 0
    }
    last_index := 0
    loop, % splitted_indexs.Length()
    {
        split_index := splitted_indexs[A_Index]
        if( split_index >= start_pos ){
            break
        }
        last_index := split_index
    }
    return last_index
}

SplittedIndexsGetRightWordPos(splitted_indexs, start_pos)
{
    local
    last_index := start_pos
    loop, % splitted_indexs.Length()
    {
        split_index := splitted_indexs[A_Index]
        if( split_index > start_pos ){
            last_index := split_index
            break
        }
    }
    return last_index
}
