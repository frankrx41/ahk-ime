;*******************************************************************************
; Radical
;
RadicalInitialize()
{
    local
    global ime_radical_table    := {}
    global ime_radicals_pinyin  := {}
    global ime_radical_atomic   := ""

    FileRead, file_content, data\radicals.txt
    Loop, Parse, file_content, `n, `r
    {
        if( SubStr(A_LoopField, 1, 1) != ";" )
        {
            ; Split each line by the tab character
            arr := StrSplit(A_LoopField, A_Tab,, 2)
            data := StrSplit(arr[2], " ")
            ime_radical_table[arr[1]] := data
        }
    }
    Assert(ime_radical_table.Count() != 0)

    FileRead, file_content, data\radicals-pinyin.txt
    index := 0
    radical_atomic_start := false
    Loop, Parse, file_content, `n, `r
    {
        line := A_LoopField
        if( line == "#radical_atomic_start" ) {
            radical_atomic_start := true
        }
        if( line == "#radical_atomic_end" ) {
            radical_atomic_start := false
        }
        if( line && SubStr(line, 1, 1) != ";" )
        {
            arr := StrSplit(line, " ")
            ime_radicals_pinyin[arr[1]] := arr[2]
            if( radical_atomic_start )
            {
                ime_radical_atomic .= arr[1]
            }
        }
    }
    Assert(ime_radicals_pinyin.Count() != 0)
}

;*******************************************************************************
; "派" -> ["氵", "𠂢"]
RadicalWordSplit(single_word)
{
    global ime_radical_table
    return ime_radical_table[single_word]
}

RadicalGetPinyin(single_radical)
{
    local
    global ime_radicals_pinyin
    return ime_radicals_pinyin[single_radical]
}

; Atomic radical should no continue split
RadicalIsAtomic(single_word)
{
    global ime_radical_atomic
    return InStr(ime_radical_atomic, single_word)
}

;*******************************************************************************
;
RadicalMatchFirstPart(test_word, ByRef test_radical, ByRef remain_radicals)
{
    test_pinyin := RadicalGetPinyin(test_word)
    if( test_pinyin == SubStr(test_radical, 1, 1) ) {
        test_radical := SubStr(test_radical, 2)
        return true
    }
    if( test_pinyin == SubStr(test_radical, 0, 1) ) {
        test_radical := SubStr(test_radical, 1, StrLen(test_radical)-1)
        return true
    }
    if( RadicalIsAtomic(test_word) ){
        return false
    }

    radical_word_list := RadicalWordSplit(test_word)
    first_word := radical_word_list[1]

    loop, % radical_word_list.Length()-1
    {
        remain_radicals[remain_radicals.Length()+A_Index] := radical_word_list[A_Index+1]
    }

    Assert(first_word != test_word, test_word, true)
    return RadicalMatchFirstPart(first_word, test_radical, remain_radicals)
}

RadicalMatchLastPart(test_word, ByRef test_radical)
{
    test_pinyin := RadicalGetPinyin(test_word)
    if( test_pinyin == SubStr(test_radical, 0, 1) ) {
        test_radical := SubStr(test_radical, 1, StrLen(test_radical)-1)
        return true
    }
    if( test_pinyin == SubStr(test_radical, 1, 1) ) {
        test_radical := SubStr(test_radical, 2)
        return true
    }
    if( RadicalIsAtomic(test_word) ){
        return false
    }

    radical_word_list := RadicalWordSplit(test_word)
    last_word := radical_word_list[radical_word_list.Length()]

    Assert(last_word != test_word, test_word, true)
    return RadicalMatchLastPart(last_word, test_radical)
}

;*******************************************************************************
;
RadicalIsFullMatch(test_word, test_radical)
{
    radical_word_list := CopyObj(RadicalWordSplit(test_word))
    loop
    {
        if( test_radical == "" ){
            return true
        }
        if( radical_word_list.Length() == 0 || ){
            return false
        }

        has_part_same := false

        ; Check if is part of first char
        ; e.g. 干 -> 二 丨, "一" H and "二" E both think match
        if( !has_part_same )
        {
            first_word := radical_word_list[1]
            remain_radicals := []
            if( RadicalMatchFirstPart(first_word, test_radical, remain_radicals) )
            {
                radical_word_list.RemoveAt(1)
                loop, % remain_radicals.Length()
                {
                    radical_word_list.InsertAt(1, remain_radicals[A_Index])
                }
                has_part_same := true
            }
        }

        ; e.g. 肉 -> 冂 仌, "人" R will also be match
        if( !has_part_same )
        {
            last_word := radical_word_list[radical_word_list.Length()]
            if( RadicalMatchLastPart(last_word, test_radical) )
            {
                radical_word_list.RemoveAt(radical_word_list.Length())
                has_part_same := true
            }
        }

        if( !has_part_same )
        {
            return false
        }
    }
}

;*******************************************************************************
; radical_list: ["SS", "YZ", "RE"]
TranslatorResultFilterByRadical(ByRef search_result, radical_list)
{
    local

    if( radical_list )
    {
        ImeProfilerBegin(36)
        index := 1
        loop % search_result.Length()
        {
            word_value := search_result[index, 2]
            should_remove := false
            ; loop each character of "我爱你"
            loop % search_result[index, 5]
            {
                test_radical := radical_list[A_Index]
                if( test_radical )
                {
                    test_word := SubStr(word_value, A_Index, 1)
                    if( !RadicalIsFullMatch(test_word, test_radical) )
                    {
                        should_remove := true
                    }
                }
                if( should_remove ){
                    break
                }
            }

            if( should_remove ) {
                search_result.RemoveAt(index)
            } else {
                index += 1
            }
        }

        ; "Radical: [" radical_list "] " "(" found_result.Length() ") " ; "(" A_TickCount - begin_tick ") "
        ImeProfilerEnd(36)
    }
}
