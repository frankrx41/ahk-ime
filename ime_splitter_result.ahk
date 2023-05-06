;*******************************************************************************
; splitter_result
;   [1]:
;       [1]: "wo"       ; 拼音
;       [2]: 3          ; 音调 0 任意音，1~5 具体音
;       [3]: "S"        ; 辅助码
;       [4]: 1          ; 原始字符串中开始的位置
;       [5]: 3          ; 原始字符串中结束的位置
;       [6]: true       ; 需要翻译该词条
;       [7]: 1          ; 期待单词长度
;       [8]: false      ; 不是完整的单词 (拼音末尾是 %)
;
SplitterResultMake(pinyin, tone, radical, start_pos, end_pos, need_translate:=true, hope_len:=1)
{
    is_completed := SubStr(pinyin, 0, 1) != "%"
    return [pinyin, tone, radical, start_pos, end_pos, need_translate, hope_len, is_completed]
}

;*******************************************************************************
;
SplitterResultGetPinyin(splitter_result) {
    return splitter_result[1]
}
SplitterResultGetTone(splitter_result) {
    return splitter_result[2]
}
SplitterResultGetRadical(splitter_result) {
    return splitter_result[3]
}
SplitterResultGetStartPos(splitter_result) {
    return splitter_result[4]
}
SplitterResultGetEndPos(splitter_result) {
    return splitter_result[5]
}
SplitterResultNeedTranslate(splitter_result) {
    return splitter_result[6]
}
SplitterResultGetHopeLength(splitter_result) {
    return splitter_result[7]
}
SplitterResultIsCompleted(splitter_result) {
    return splitter_result[8]
}

;*******************************************************************************
;
; Action about splitted indexs
SplitterResultArrayGetIndex(splitter_result_arr, caret_pos)
{
    local
    if( splitter_result_arr.Length() >= 1)
    {
        if( SplitterResultGetEndPos(splitter_result_arr[splitter_result_arr.Length()]) == caret_pos )
        {
            return splitter_result_arr.Length()
        }
        loop % splitter_result_arr.Length()
        {
            if( SplitterResultGetEndPos(splitter_result_arr[A_Index]) > caret_pos ){
                return A_Index
            }
        }
        ; TODO: fix this
        ; Assert(false, SplitterResultArrayGetDisplayText(splitter_result_arr) "," caret_pos)
    }
    return 1
}

;*******************************************************************************
;
SplitterResultArrayGetCurrentWordPos(splitter_result_arr, caret_pos)
{
    local
    if( caret_pos == 0 ){
        return 0
    }
    last_index := 0
    loop, % splitter_result_arr.Length()
    {
        split_index := SplitterResultGetEndPos(splitter_result_arr[A_Index])
        if( split_index >= caret_pos ){
            last_index := split_index
            break
        }
    }
    return last_index
}


SplitterResultArrayGetLeftWordPos(splitter_result_arr, caret_pos)
{
    local
    if( caret_pos == 0 ){
        return 0
    }
    last_index := 0
    loop, % splitter_result_arr.Length()
    {
        split_index := SplitterResultGetEndPos(splitter_result_arr[A_Index])
        if( split_index >= caret_pos ){
            break
        }
        last_index := split_index
    }
    return last_index
}

SplitterResultArrayGetRightWordPos(splitter_result_arr, caret_pos)
{
    local
    last_index := caret_pos
    loop, % splitter_result_arr.Length()
    {
        split_index := SplitterResultGetEndPos(splitter_result_arr[A_Index])
        if( split_index > caret_pos ){
            last_index := split_index
            break
        }
    }
    return last_index
}

;*******************************************************************************
;
SplitterResultArrayGetUntilSkip(splitter_result_arr, start_count := 1)
{
    local
    return_splitter_result := []
    if( !SplitterResultNeedTranslate(splitter_result_arr[start_count]) )
    {
        return_splitter_result[1] := splitter_result_arr[start_count]
    }
    find_string := ""
    loop, % splitter_result_arr.Length()
    {
        if( A_Index < start_count ) {
            continue
        }
        if( SplitterResultNeedTranslate(splitter_result_arr[A_Index]) )
        {
            return_splitter_result.Push(splitter_result_arr[A_Index])
        }
        else
        {
            break
        }
    }
    return return_splitter_result
}

SplitterResultArrayGetUntilLength(splitter_result_arr, start_count := 1)
{
    local
    return_splitter_result := []
    if( SplitterResultGetHopeLength(splitter_result_arr[start_count])==1 )
    {
        return_splitter_result[1] := splitter_result_arr[start_count]
    }
    find_string := ""
    loop, % splitter_result_arr.Length()
    {
        if( A_Index < start_count ) {
            continue
        }
        return_splitter_result.Push(splitter_result_arr[A_Index])
        if( SplitterResultGetHopeLength(splitter_result_arr[A_Index])==1 )
        {
            break
        }
    }
    return return_splitter_result
}

SplitterResultArrayConvertToString(splitter_result_arr, start_count, ByRef inout_length_count := 0)
{
    local
    find_string := ""
    word_length := 0
    if( inout_length_count == 0 ){
        inout_length_count := splitter_result_arr.Length()
    }
    if( start_count == 0 ){
        start_count := splitter_result_arr.Length()
    }
    loop, % splitter_result_arr.Length()
    {
        if( A_Index < start_count ) {
            continue
        }
        if( inout_length_count <= 0 ){
            break
        }
        inout_length_count -= 1
        word_length += 1
        find_string .= SplitterResultGetPinyin(splitter_result_arr[A_Index])
        find_string .= SplitterResultGetTone(splitter_result_arr[A_Index])
    }
    inout_length_count := word_length
    return find_string
}

;*******************************************************************************
;
SplitterResultArrayGetDisplayText(splitter_result_arr)
{
    local
    dsiplay_text := ""
    loop, % splitter_result_arr.Length()
    {
        index := A_Index
        if( SplitterResultNeedTranslate(splitter_result_arr[index]) )
        {
            dsiplay_text .= SplitterResultGetPinyin(splitter_result_arr[index])
            dsiplay_text .= SplitterResultGetTone(splitter_result_arr[index])
        }
        else
        {
            dsiplay_text .= "<"
            dsiplay_text .= SplitterResultGetPinyin(splitter_result_arr[index])
            dsiplay_text .= ">"
        }

        radical := SplitterResultGetRadical(splitter_result_arr[index])
        if( radical ) {
            dsiplay_text .= "{" radical "}"
        }

        length := SplitterResultGetHopeLength(splitter_result_arr[index])
        dsiplay_text .= "=" length ""

        ; dsiplay_text .= " ("
        ; dsiplay_text .= SplitterResultGetStartPos(splitter_result_arr[index])
        ; dsiplay_text .= ","
        ; dsiplay_text .= SplitterResultGetEndPos(splitter_result_arr[index])
        ; dsiplay_text .= ")"

        dsiplay_text .= ","
    }
    return SubStr(dsiplay_text, 1, StrLen(dsiplay_text)-1)
}