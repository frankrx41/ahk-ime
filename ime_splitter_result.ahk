;*******************************************************************************
; splitter_result
;   [1]:
;       [1]: "wo"       ; 拼音
;       [2]: 3          ; 音调 0 任意音，1~5 具体音
;       [3]: "S"        ; 辅助码
;       [4]: 1          ; 原始字符串中开始的位置
;       [5]: 3          ; 原始字符串中结束的位置
;       [6]: true       ; 可以进行翻译
;       [7]: 1          ; 期待单词长度
;
SplitterResultPush(ByRef splitter_result, pinyin, tone, radical, start_pos, end_pos, skip:=false)
{
    splitter_result.Push([pinyin, tone, radical, start_pos, end_pos, skip, 1])
}

SplitterResultSetWordLength(ByRef splitter_result, index, length)
{
    splitter_result[index, 7] := length
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

SplitterResultGetWordLength(ByRef splitter_result, index)
{
    return splitter_result[index, 7]
}

;*******************************************************************************
;
; Action about splitted indexs
SplittedIndexsGetPosIndex(splitter_result, caret_pos)
{
    local
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
SplitterResultGetUntilSkip(splitter_result, start_count := 1)
{
    local
    return_splitter_result := []
    if( SplitterResultIsSkip(splitter_result, start_count) )
    {
        return_splitter_result[1] := splitter_result[start_count]
    }
    find_string := ""
    loop, % splitter_result.Length()
    {
        if( A_Index < start_count ) {
            continue
        }
        if( !SplitterResultIsSkip(splitter_result, A_Index) )
        {
            return_splitter_result.Push(splitter_result[A_Index])
        }
        else
        {
            break
        }
    }
    return return_splitter_result
}

SplitterResultConvertToString(splitter_result, start_count, ByRef inout_length_count := 0)
{
    local
    find_string := ""
    word_length := 0
    if( inout_length_count == 0 ){
        inout_length_count := splitter_result.Length()
    }
    if( start_count == 0 ){
        start_count := splitter_result.Length()
    }
    loop, % splitter_result.Length()
    {
        if( A_Index < start_count ) {
            continue
        }
        if( inout_length_count <= 0 ){
            break
        }
        inout_length_count -= 1
        word_length += 1
        find_string .= SplitterResultGetPinyin(splitter_result, A_Index)
        find_string .= SplitterResultGetTone(splitter_result, A_Index)
    }
    inout_length_count := word_length
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
        if( !SplitterResultIsSkip(splitter_result, index) )
        {
            dsiplay_text .= SplitterResultGetPinyin(splitter_result, index)
            dsiplay_text .= SplitterResultGetTone(splitter_result, index)
        }
        else
        {
            dsiplay_text .= "<"
            dsiplay_text .= SplitterResultGetPinyin(splitter_result, index)
            dsiplay_text .= ">"
        }

        radical := SplitterResultGetRadical(splitter_result, index)
        if( radical ) {
            dsiplay_text .= "{" radical "}"
        }

        length := SplitterResultGetWordLength(splitter_result, index)
        dsiplay_text .= "=" length ""

        ; dsiplay_text .= " ("
        ; dsiplay_text .= SplitterResultGetStartPos(splitter_result, index)
        ; dsiplay_text .= ","
        ; dsiplay_text .= SplitterResultGetEndPos(splitter_result, index)
        ; dsiplay_text .= ")"

        dsiplay_text .= ","
    }
    return SubStr(dsiplay_text, 1, StrLen(dsiplay_text)-1)
}