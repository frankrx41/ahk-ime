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

PinyinResultFilterByRadical(ByRef search_result, radical_list)
{
    local
    global tooltip_debug

    if( radical_list )
    {
        begin_tick := A_TickCount
        index := 1
        loop % search_result.Length()
        {
            word_value := search_result[index, 2]
            sould_remove := false
            loop % StrLen(word_value)
            {
                test_radical := radical_list[A_Index]
                if( test_radical )
                {
                    word := SubStr(word_value, A_Index, 1)
                    test_pinyin := RadicalGetPinyin(WordGetRadical(word))
                    content_radical := InStr(test_pinyin, test_radical)
                    same_as_radical := radical_list == word_value
                    if( !content_radical && !same_as_radical )
                    {
                        sould_remove := true
                        break
                    }
                }
            }

            if( sould_remove ) {
                search_result.RemoveAt(index)
            } else {
                index += 1
            }
        }

        ; tooltip_debug[26] := "Radical: [" radical_list "] " "(" found_result.Length() ") " ; "(" A_TickCount - begin_tick ") "
        ImeProfilerPlusTick(26, A_TickCount - begin_tick)
    }
}
