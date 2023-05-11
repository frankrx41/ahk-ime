PinyinTraditionalInitialize()
{
    global ime_traditional_table := {}
    FileRead, file_content, data\traditional.txt
    Loop, Parse, file_content, `n, `r
    {
        ; Split each line by the tab character
        arr := StrSplit(A_LoopField, "`t")
        ime_traditional_table[arr[1]] := StrSplit(arr[2], " ")
    }
    Assert(ime_traditional_table.Count() != 0)
}

PinyinResultTraditionalUpdate(ByRef translate_result_list, index, tranditional_word, comment:="*")
{
    translate_result := translate_result_list[index]
    pinyin := TranslatorResultGetPinyin(translate_result)
    word_length := TranslatorResultGetWordLength(translate_result)
    weight := TranslatorResultGetWeight(translate_result)
    comment .= TranslatorResultGetComment(translate_result)

    single_result := TranslatorResultMake(pinyin, tranditional_word, weight, comment, word_length)

    translate_result_list.RemoveAt(index, 1)
    translate_result_list.InsertAt(index, single_result)
}

PinyinResultCovertTraditional(ByRef translate_result_list)
{
    local
    global ime_traditional_table

    ; Some times one simplified word can convert to multiple tranditional word
    additional_result_info := {}

    loop, % translate_result_list.Length()
    {
        translate_result := translate_result_list[A_Index]
        simplified_word := TranslatorResultGetWord(translate_result)
        if( ime_traditional_table[simplified_word] )
        {
            pinyin := TranslatorResultGetPinyin(translate_result)
            word_length := TranslatorResultGetWordLength(translate_result)
            PinyinResultTraditionalUpdate(translate_result_list, A_Index, ime_traditional_table[simplified_word, 1])

            if( ime_traditional_table[simplified_word].Length() > 1 )
            {
                additional_result_info.Push([A_Index, simplified_word, pinyin, word_length])
            }
        }
        else if( StrLen(simplified_word) > 1 )
        {
            traditional_result_word := ""
            loop, Parse, simplified_word
            {
                traditional_word := ime_traditional_table[A_LoopField, 1]
                if( traditional_word ) {
                    ; traditional_result_word .= A_LoopField "(" traditional_word ")"
                    traditional_result_word .= traditional_word
                } else {
                    traditional_result_word .= A_LoopField
                }
            }
            if( traditional_result_word != TranslatorResultGetWord(translate_result_list[A_Index]) )
            {
                PinyinResultTraditionalUpdate(translate_result_list, A_Index, traditional_result_word)
            }
        }
    }

    offset_index := 0
    loop, % additional_result_info.Length()
    {
        index := additional_result_info[A_Index, 1] + offset_index
        simplified_word := additional_result_info[A_Index, 2]
        pinyin := additional_result_info[A_Index, 3]
        length := additional_result_info[A_Index, 4]
        loop, % ime_traditional_table[simplified_word].Length() - 1
        {
            traditional_word := ime_traditional_table[simplified_word, A_Index+1]
            index += 1
            offset_index += 1
            single_result := TranslatorResultMake(pinyin, traditional_word, 0, "+", length)
            translate_result_list.InsertAt(index, single_result)
        }
    }
}
