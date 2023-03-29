;*******************************************************************************
; 辅助码相关
;
PinyinRadicalInitialize()
{
    local
    global ime_radical_table := {}
    global ime_radicals_pinyin := {}

    FileRead, file_content, data\radicals.txt
    Loop, Parse, file_content, `n
    {
        ; Split each line by the tab character
        arr := StrSplit(StrReplace(A_LoopField, "`r"), A_Tab,, 2)
        data := StrSplit(arr[2], " ")
        ime_radical_table[arr[1]] := data
    }
    Assert(ime_radical_table.Count() != 0)

    FileRead, file_content, data\radicals-pinyin.txt
    index := 0
    Loop, Parse, file_content, `n
    {
        arr := StrSplit(StrReplace(A_LoopField, "`r"), " ")
        ime_radicals_pinyin[arr[1]] := arr[2]
    }
    Assert(ime_radicals_pinyin.Count() != 0)
}

; 辅助码构成反查
; "派" -> ["氵", "𠂢"]
PinyinRadicalWordGetRadical(single_word)
{
    global ime_radical_table
    return ime_radical_table[single_word]
}

PinyinRadicalGetPinyin(single_radical)
{
    local
    global ime_radicals_pinyin
    return ime_radicals_pinyin[single_radical]
}

; "CR" + "幕" -> ""
; "CCC" + "艹" -> "CC"
PinyinRadicalGetRemoveUsedPart(test_radical, test_word, check_first:=false)
{
    radical_word_list := PinyinRadicalWordGetRadical(test_word)
    loop
    {
        if( radical_word_list.Length() == 0 || test_radical == ""){
            return test_radical
        }

        first_word := radical_word_list[1]
        test_pinyin := PinyinRadicalGetPinyin(first_word)

        ; Check only first word
        has_part_same := false
        if( check_first )
        {
            if( SubStr(test_radical, 1, 1) == test_pinyin )
            {
                test_radical := StrReplace(test_radical, test_pinyin, "",, 1)
            }
            return test_radical
        }

        ; Check first word
        if( SubStr(test_radical, 1, 1) == test_pinyin || SubStr(test_radical, 0, 1) == test_pinyin ) {
            test_radical := StrReplace(test_radical, test_pinyin, "",, 1)
            has_part_same := true
            radical_word_list.RemoveAt(1)
        }
        ; Check last word
        else
        {
            last_word := radical_word_list[radical_word_list.Length()]
            test_pinyin := PinyinRadicalGetPinyin(last_word)
            if( SubStr(test_radical, 1, 1) == test_pinyin || SubStr(test_radical, 0, 1) == test_pinyin ) {
                test_radical := StrReplace(test_radical, test_pinyin, "",, 1)
                has_part_same := true
                radical_word_list.RemoveAt(radical_word_list.Length())
            }
        }

        if( !has_part_same )
        {
            origin_test_radical := test_radical
            test_radical := PinyinRadicalGetRemoveUsedPart(test_radical, first_word, true)
            if( test_radical == origin_test_radical )
            {
                return test_radical
            }
            radical_word_list.RemoveAt(1)
        }
    }
}

PinyinResultIsAllPartOfRadical(test_radical, test_word)
{
    if( PinyinRadicalGetRemoveUsedPart(test_radical, test_word) == "" )
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
