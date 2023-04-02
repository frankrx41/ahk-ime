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

        dsiplay_text .= ", "
    }
    return SubStr(dsiplay_text, 1, StrLen(dsiplay_text)-2)
}