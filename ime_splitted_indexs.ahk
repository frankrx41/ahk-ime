; Action about splitted indexs
SplittedIndexsGetPosIndex(split_indexs, caret_pos)
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
        Assert(false, split_indexs.Length() "," caret_pos)
    }
    return 1
}

SplittedIndexsGetLeftWordPos(split_indexs, start_pos)
{
    local
    if( start_pos == 0 ){
        return 0
    }
    last_index := 0
    loop, % split_indexs.Length()
    {
        split_index := split_indexs[A_Index]
        if( split_index >= start_pos ){
            break
        }
        last_index := split_index
    }
    return last_index
}

SplittedIndexsGetRightWordPos(split_indexs, start_pos)
{
    local
    last_index := start_pos
    loop, % split_indexs.Length()
    {
        split_index := split_indexs[A_Index]
        if( split_index > start_pos ){
            last_index := split_index
            break
        }
    }
    return last_index
}
