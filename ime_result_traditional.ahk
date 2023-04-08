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

PinyinResultCovertTraditional(ByRef translate_result)
{
    local
    global ime_traditional_table
    insert_indexs := {}
    loop, % translate_result.Length()
    {
        result_word := TranslatorResultGetWord(translate_result, A_Index)
        if( ime_traditional_table[result_word] )
        {
            ; TODO: clear code
            pinyin := TranslatorSingleResultGetPinyin(translate_result)
            length := TranslatorSingleResultGetWordLength(translate_result)
            TranslatorResultSetWord(translate_result, A_Index, ime_traditional_table[result_word, 1])
            TranslatorResultSetComment(translate_result, A_Index, "*" . TranslatorResultGetComment(translate_result, A_Index))
            if( ime_traditional_table[result_word].Length() > 1 )
            {
                insert_indexs.Push([A_Index, result_word, pinyin, length])
            }
        }
        else if( StrLen(result_word) > 1 )
        {
            traditional_result_word := ""
            loop, Parse, result_word
            {
                traditional_word := ime_traditional_table[A_LoopField, 1]
                if( traditional_word ) {
                    ; traditional_result_word .= A_LoopField "(" traditional_word ")"
                    traditional_result_word .= traditional_word
                } else {
                    traditional_result_word .= A_LoopField
                }
            }
            if( traditional_result_word != translate_result[A_Index, 2] )
            {
                TranslatorResultSetWord(translate_result, A_Index, traditional_result_word)
                TranslatorResultSetComment(translate_result, A_Index, "*" . TranslatorResultGetComment(translate_result, A_Index))
            }
        }
    }

    offset_index := 0
    loop, % insert_indexs.Length()
    {
        index := insert_indexs[A_Index, 1] + offset_index
        result_word := insert_indexs[A_Index, 2]
        pinyin := insert_indexs[A_Index, 3]
        length := insert_indexs[A_Index, 4]
        loop, % ime_traditional_table[result_word].Length() - 1
        {
            traditional_word := ime_traditional_table[result_word, A_Index+1]
            index += 1
            offset_index += 1
            translate_result.InsertAt(index, [pinyin, traditional_word, 0, "+", length])
        }
    }
}
