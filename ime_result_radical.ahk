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

; "CR" + "幕" -> ""
; "CCC" + "艹" -> "CC"
PinyinRadicalGetRemoveUsedPart(test_radical, test_word, depth)
{
    radical_words := WordGetRadical(test_word)
    loop
    {
        if( radical_words == "" || test_radical == ""){
            return test_radical
        }

        first_word := SubStr(radical_words, 1, 1)
        test_pinyin := RadicalGetPinyin(first_word)
        radical_words := SubStr(radical_words, 2)

        has_part_same := false
        if( SubStr(test_radical, 1, 1) == test_pinyin || SubStr(test_radical, 0, 1) == test_pinyin ) {
            test_radical := StrReplace(test_radical, test_pinyin, "",, 1)
            has_part_same := true
        }

        if( !has_part_same && depth)
        {
            origin_test_radical := test_radical
            test_radical := PinyinRadicalGetRemoveUsedPart(test_radical, first_word, depth-1)
            if( test_radical == origin_test_radical )
            {
                return test_radical
            }
        }
    }
}

PinyinResultIsAllPartOfRadical(test_radical, test_word)
{
    if( PinyinRadicalGetRemoveUsedPart(test_radical, test_word, 1) == "" )
    {
        return true
    }
    return false
}

; radical_list: ["SS", "YZ", "RE"]
PinyinResultFilterByRadical(ByRef search_result, radical_list)
{
    local

    if( radical_list )
    {
        ImeProfilerBegin(26)
        index := 1
        loop % search_result.Length()
        {
            word_value := search_result[index, 2]
            sould_remove := false
            ; loop each character of "我爱你"
            loop % search_result[index, 5]
            {
                test_radical := radical_list[A_Index]
                if( test_radical )
                {
                    test_word := SubStr(word_value, A_Index, 1)
                    if( test_word == "荩" )
                    {
                        foo := 1
                    }
                    if( !PinyinResultIsAllPartOfRadical(test_radical, test_word) )
                    {
                        sould_remove := true
                    }
                }
                if( sould_remove ){
                    break
                }
            }

            if( sould_remove ) {
                search_result.RemoveAt(index)
            } else {
                index += 1
            }
        }

        ; "Radical: [" radical_list "] " "(" found_result.Length() ") " ; "(" A_TickCount - begin_tick ") "
        ImeProfilerEnd(26)
    }
}
