;*******************************************************************************
; splitter_result
;   [1]:
;       [1,1]: "wo"     ; 拼音
;       [1,2]: 3        ; 音调 0 任意音，1~5 具体音
;       [1,3]: "S"      ; 辅助码
;       [1,4]: 1        ; 原始字符串中开始的位置
;       [1,5]: 3        ; 原始字符串中结束的位置
;       [1,6]: true     ; 可以进行翻译
;
SplitterResultPush(ByRef splitter_result, pinyin, tone, radical, start_pos, end_pos, skip:=false)
{
    splitter_result.Push([pinyin, tone, radical, start_pos, end_pos, skip])
}

;*******************************************************************************
;
SplitterResultGetPinyin(ByRef splitter_result, index)
{
    return splitter_result[index, 1]
}

SplitterResultGetTone(ByRef splitter_result, index)
{
    return splitter_result[index, 2]
}

SplitterResultGetRadical(ByRef splitter_result, index)
{
    return splitter_result[index, 3]
}

SplitterResultGetStartPos(ByRef splitter_result, index)
{
    return splitter_result[index, 4]
}

SplitterResultGetEndPos(ByRef splitter_result, index)
{
    return splitter_result[index, 5]
}

SplitterResultIsSkip(ByRef splitter_result, index)
{
    return splitter_result[index, 6]
}

;*******************************************************************************
;
; Action about splitted indexs
SplittedIndexsGetPosIndex(splitter_result, caret_pos)
{
    if( splitter_result.Length() >= 1)
    {
        if( SplitterResultGetEndPos(splitter_result, splitter_result.Length()) == caret_pos )
        {
            return splitter_result.Length()
        }
        loop % splitter_result.Length()
        {
            if( SplitterResultGetEndPos(splitter_result, A_Index) > caret_pos ){
                return A_Index
            }
        }
        Assert(false, SplitterResultGetDisplayText(splitter_result) "," caret_pos)
    }
    return 1
}

SplittedIndexsGetLeftWordPos(splitter_result, start_pos)
{
    local
    if( start_pos == 0 ){
        return 0
    }
    last_index := 0
    loop, % splitter_result.Length()
    {
        split_index := SplitterResultGetEndPos(splitter_result, A_Index)
        if( split_index >= start_pos ){
            break
        }
        last_index := split_index
    }
    return last_index
}

SplittedIndexsGetRightWordPos(splitter_result, start_pos)
{
    local
    last_index := start_pos
    loop, % splitter_result.Length()
    {
        split_index := SplitterResultGetEndPos(splitter_result, A_Index)
        if( split_index > start_pos ){
            last_index := split_index
            break
        }
    }
    return last_index
}

;*******************************************************************************
;
SplitterResultConvertToStringUntilSkip(splitter_result, start_count := 1)
{
    if( SplitterResultIsSkip(splitter_result, start_count) )
    {
        return SplitterResultGetPinyin(splitter_result, start_count)
    }
    find_string := ""
    loop, % splitter_result.Length()
    {
        if( A_Index < start_count ) {
            continue
        }
        if( !SplitterResultIsSkip(splitter_result, A_Index) )
        {
            find_string .= SplitterResultGetPinyin(splitter_result, A_Index)
            find_string .= SplitterResultGetTone(splitter_result, A_Index)
        }
        else
        {
            break
        }
    }
    return find_string
}

SplitterResultConvertToString(splitter_result, start_count, length_count := 1)
{
    find_string := ""
    loop, % splitter_result.Length()
    {
        if( A_Index < start_count ) {
            continue
        }
        if( length_count <= 0 ){
            break
        }
        length_count -= 1
        find_string .= SplitterResultGetPinyin(splitter_result, A_Index)
        find_string .= SplitterResultGetTone(splitter_result, A_Index)
    }
    return find_string
}

;*******************************************************************************
;
SplitterResultGetDisplayText(splitter_result)
{
    local
    dsiplay_text := ""
    loop, % splitter_result.Length()
    {
        index := A_Index
        dsiplay_text .= SplitterResultGetPinyin(splitter_result, index)
        dsiplay_text .= SplitterResultGetTone(splitter_result, index)
        
        radical := SplitterResultGetRadical(splitter_result, index)
        if( radical ) {
            dsiplay_text .= "{" radical "}"
        }

        ; dsiplay_text .= " ("
        ; dsiplay_text .= SplitterResultGetStartPos(splitter_result, index)
        ; dsiplay_text .= ","
        ; dsiplay_text .= SplitterResultGetEndPos(splitter_result, index)
        ; dsiplay_text .= ")"

        dsiplay_text .= ","
    }
    return SubStr(dsiplay_text, 1, StrLen(dsiplay_text)-1)
}