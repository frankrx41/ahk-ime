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

PinyinResultCovertTraditional(ByRef search_result)
{
    local
    global ime_traditional_table
    insert_indexs := {}
    loop, % search_result.Length()
    {
        result_word := search_result[A_Index, 2]
        if( ime_traditional_table[result_word] )
        {
            pinyin := search_result[A_Index, 1]
            length := search_result[A_Index, 5]
            search_result[A_Index, 2] := ime_traditional_table[result_word, 1]
            search_result[A_Index, 4] := "*" . search_result[A_Index, 4]
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
                    break
                }
            }
            if( traditional_result_word != search_result[A_Index, 2] )
            {
                search_result[A_Index, 2] := traditional_result_word
                search_result[A_Index, 4] := "*" . search_result[A_Index, 4]
            }
        }
    }

    loop, % insert_indexs.Length()
    {
        index := insert_indexs[A_Index, 1]
        result_word := insert_indexs[A_Index, 2]
        pinyin := insert_indexs[A_Index, 3]
        length := insert_indexs[A_Index, 4]
        loop, % ime_traditional_table[result_word].Length() - 1
        {
            tranditional_word := ime_traditional_table[result_word, A_Index+1]
            index += 1
            search_result.InsertAt(index, [pinyin, tranditional_word, 0, "+", length])
        }
    }
}
