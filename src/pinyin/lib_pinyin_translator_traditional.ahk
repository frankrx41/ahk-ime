PinyinTraditionalInitialize()
{
    global ime_traditional_table
    static ime_traditional_initialize := false
    if( ime_traditional_initialize ){
        return
    }
    ime_traditional_table := {}
    FileRead, file_content, data\traditional.txt
    Loop, Parse, file_content, `n, `r
    {
        line := A_LoopField
        ; Split each line by the tab char
        if( line != "" && SubStr(line, 1, 1) != ";" )
        {
            arr := StrSplit(line, "`t")
            ime_traditional_table[arr[1]] := StrSplit(arr[2], ",")
        }
    }
    ime_traditional_initialize := true
    Assert(ime_traditional_table.Count() != 0)
}

PinyinTranslatorCovertTraditional(ByRef translate_result_list)
{
    local
    global ime_traditional_table

    index := 1
    loop
    {
        if( index >= translate_result_list.Length() ){
            break
        }
        translate_result := translate_result_list[index]
        simplified_word := TranslatorResultGetWord(translate_result)
        if( ime_traditional_table[simplified_word] )
        {
            translate_result_list.RemoveAt(index, 1)
            loop, % ime_traditional_table[simplified_word].Length()
            {
                tranditional_word := ime_traditional_table[simplified_word, A_Index]
                tranditional_translate_result := TranslatorResultMakeTraditional(translate_result, tranditional_word)

                translate_result_list.InsertAt(index, tranditional_translate_result)
                index += 1
            }
            index -= 1
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
            if( traditional_result_word != TranslatorResultGetWord(translate_result) )
            {
                tranditional_word := ime_traditional_table[simplified_word, A_Index]
                tranditional_translate_result := TranslatorResultMakeTraditional(translate_result, traditional_result_word)

                translate_result_list.RemoveAt(index, 1)
                translate_result_list.InsertAt(index, tranditional_translate_result)
            }
        }
        index += 1
    }
}
