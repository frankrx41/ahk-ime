;*******************************************************************************
; 辅助码相关
;
PinyinAssistantInitialize()
{
    local
    global assistant_table := {}
    global assistant_pinyin := {}

    FileRead, file_content, data\radicals.txt
    Loop, Parse, file_content, `n
    {
        ; Split each line by the tab character
        arr := StrSplit(A_LoopField, A_Tab,, 2)
        
        ; Store the first word as the key and the rest as the value
        data := RegExReplace(arr[2], "[ `n`r]")
        data := StrSplit(data, A_Tab)
        assistant_table[arr[1]] := data
    }
    Assert(assistant_table.Count() != 0)

    FileRead, file_content, data\radicals-pinyin.txt
    index := 0
    Loop, Parse, file_content, `n
    {
        arr := StrSplit(A_LoopField)
        assistant_pinyin[arr[1]] := arr[2]
    }
    Assert(assistant_pinyin.Count() != 0)
}

PinyinResultUpdateAssistant(ByRef search_result)
{
    local
    loop % search_result.Length()
    {
        if( search_result[A_Index, 6] == "" )
        {
            search_result[A_Index, 6] := GetAssistantTable(search_result[A_Index, 2])
        }
    }
}

; 辅助码构成反查
GetAssistantTable(str, max_cnt:=1)
{
    local
    global assistant_table
    len := StrLen(str)
    result := ""
    if( len == 1 )
    {
        loop, % max_cnt
        {
            code := assistant_table[str, A_Index]
            if( code ){
                result .= result ? "," : ""
                result .= SubStr(code, 1, 1) . SubStr(code, 0, 1)
            }
        }
    }
    else
    {
        ; 每字第一码
        loop, Parse, str
        {
            code := assistant_table[A_LoopField, 1]
            result .= SubStr(code, 1, 1)
        }
    }
    return result
}

PinyinAssistantGetPinyin(assistant)
{
    local
    global assistant_pinyin
    result_pinyin := ""
    loop, Parse, % assistant
    {
        pinyin := assistant_pinyin[A_LoopField]
        Assert(pinyin, assistant)
        result_pinyin .= pinyin
    }
    return result_pinyin
}

PinyinResultCheckAssistant(ByRef search_result, assistant_code)
{
    local
    global tooltip_debug

    if( assistant_code )
    {
        begin_tick := A_TickCount
        found_result := []
        loop % search_result.Length()
        {
            test_pinyin := PinyinAssistantGetPinyin(search_result[A_Index,6])
            content_assistant := InStr(test_pinyin, assistant_code)
            same_as_assistant := assistant_code == search_result[A_Index, 2]
            if( content_assistant || same_as_assistant )
            {
                found_result.Push(search_result[A_Index])
            }
        }

        if( found_result.Length() )
        {
            search_result := found_result
        }
        
        tooltip_debug[6] := "Assistant tick: " A_TickCount - begin_tick ", " found_result.Length() " [" assistant_code "]"
    }
}
