;*******************************************************************************
; 辅助码相关
;
PinyinRadicalInitialize()
{
    local
    global radical_table := {}
    global radicals_pinyin := {}

    FileRead, file_content, data\radicals.txt
    Loop, Parse, file_content, `n
    {
        ; Split each line by the tab character
        arr := StrSplit(A_LoopField, A_Tab,, 2)
        
        ; Store the first word as the key and the rest as the value
        data := RegExReplace(arr[2], "[ `n`r]")
        data := StrSplit(data, A_Tab)
        radical_table[arr[1]] := data
    }
    Assert(radical_table.Count() != 0)

    FileRead, file_content, data\radicals-pinyin.txt
    index := 0
    Loop, Parse, file_content, `n
    {
        arr := StrSplit(A_LoopField)
        radicals_pinyin[arr[1]] := arr[2]
    }
    Assert(radicals_pinyin.Count() != 0)
}

PinyinResultUpdateRadical(ByRef search_result)
{
    local
    loop % search_result.Length()
    {
        if( search_result[A_Index, 6] == "" )
        {
            search_result[A_Index, 6] := WordGetRadical(search_result[A_Index, 2])
        }
    }
}

; 辅助码构成反查
WordGetRadical(str, max_cnt:=1)
{
    local
    global radical_table
    len := StrLen(str)
    result := ""
    if( len == 1 )
    {
        loop, % max_cnt
        {
            code := radical_table[str, A_Index]
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
            code := radical_table[A_LoopField, 1]
            result .= SubStr(code, 1, 1)
        }
    }
    return result
}

RadicalGetPinyin(radical)
{
    local
    global radicals_pinyin
    result_pinyin := ""
    loop, Parse, % radical
    {
        pinyin := radicals_pinyin[A_LoopField]
        Assert(pinyin, radical)
        result_pinyin .= pinyin
    }
    return result_pinyin
}

PinyinResultFilterByRadical(ByRef search_result, input_radical)
{
    local
    global tooltip_debug

    if( input_radical )
    {
        begin_tick := A_TickCount
        found_result := []
        loop % search_result.Length()
        {
            test_pinyin := RadicalGetPinyin(search_result[A_Index,6])
            content_radical := InStr(test_pinyin, input_radical)
            same_as_radical := input_radical == search_result[A_Index, 2]
            if( content_radical || same_as_radical )
            {
                found_result.Push(search_result[A_Index])
            }
        }

        if( found_result.Length() )
        {
            search_result := found_result
        }
        
        tooltip_debug[6] := "Radical: [" input_radical "] " "(" found_result.Length() ") " ; "(" A_TickCount - begin_tick ") "
    }
}
