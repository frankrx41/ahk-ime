PinyinResultClear()
{
    global history_field_array := []
}

PinyinHasResult(pinyin)
{
    global history_field_array
    return history_field_array[pinyin, 1, 2] != ""
}

PinyinHasKey(pinyin)
{
    global history_field_array
    global tooltip_debug
    tooltip_debug[5] .= "`n[" pinyin ": " history_field_array.HasKey(pinyin) "]"
    return history_field_array.HasKey(pinyin)
}

PinyinUpdateKey(DB, pinyin, limit_num:=100)
{
    global history_field_array
    if( !PinyinHasKey(pinyin) || history_field_array[pinyin].Length()==2 && history_field_array[pinyin,2,2]=="" )
    {
        history_field_array[pinyin] := PinyinSqlGetResult(DB, pinyin, limit_num)
    }
}

PinyinKeyGetWords(pinyin)
{
    global history_field_array
    return history_field_array[pinyin]
}

SearchResultPush(ByRef search_result, spilt_word)
{
    global history_field_array
    loop % history_field_array[spilt_word].Length() {
        search_result.Push(CopyObj(history_field_array[spilt_word, A_Index]))
    }
}

WordCanContinueSplit(word)
{
    ; 包含 word + tone + word + ... 格式
    return RegExMatch(word, "['12345][^'12345]")
}

WordLimitMaxSplit(word, max:=8)
{
    ; "kai'xin'a'" -> "xin'a'"
    return RegExReplace(word, "^(([^'12345]+['12345]?){0," max "}).*$", "$1")
}

WordRemoveFirstSplit(word)
{
    ; "kai'xin'a'" -> "xin'a'"
    return RegExReplace(word, "^[^'12345]+['12345]?")
}

WordRemoveLastSplit(word)
{
    ; "kai'xin'a'" -> "kai'xin'"
    return RegExReplace(word, "(['12345])([^'12345]+['12345]?)$", "$1")
}

PinyinResultInsertWords(ByRef DB, input_spilt_string, ByRef search_result)
{
    local
    ; 插入候选词部分
    spilt_word := WordRemoveLastSplit(input_spilt_string)
    While( WordCanContinueSplit(spilt_word) && !PinyinHasResult(spilt_word) )
    {
        PinyinUpdateKey(DB, spilt_word)
        if( PinyinHasResult(spilt_word) ){
            break
        }
        spilt_word := WordRemoveLastSplit(spilt_word)
    }
    if( WordCanContinueSplit(spilt_word) )
    {
        PinyinUpdateKey(DB, spilt_word)
        SearchResultPush(search_result, spilt_word)
    }
    return
}

GetFirstWord(input_str)
{
    return RegExReplace(input_str, "^([a-z]+[12345'%]).*", "$1")
}

PinyinResultInsertSingleWord(ByRef DB, ByRef search_result, input_split_string)
{
    local
    first_word := GetFirstWord(input_split_string)
    PinyinUpdateKey(DB, first_word)
    SearchResultPush(search_result, first_word)
    return
}

PinyinResultHideZeroWeight(ByRef search_result)
{
    local
    if( search_result[1, 3]>0 )
    {
        loop % len := search_result.Length()
        {
            weight := search_result[len+1-A_Index, 3]
            if( weight<=0 ) {
                search_result.RemoveAt(len+1-A_Index)
            }
        }
    }
    return
}

PinyinResultRemoveZeroIndex(ByRef search_result)
{
    ; [0] is store "pinyin"
    if( search_result.HasKey(0) ){
        search_result.Delete(0)
    }
    return
}

; 拼音取词
PinyinGetSentences(ime_orgin_input, ime_input_split:="", DB:="")
{
    local
    ; static save_field_array := []
    search_result           := []
    save_field_array        := []

    if( StrLen(ime_orgin_input) == 1 && !InStr("aloe", ime_orgin_input) )
    {
        search_result[1] := [ime_orgin_input, ime_orgin_input, "N/A"]
        return search_result
    }
    else
    {
        if( ime_input_split == "" ) {
            ime_input_split := PinyinSplit(ime_orgin_input, "")
        }

        ; Do sql get result
        PinyinProcess(DB, save_field_array, ime_input_split)

        ; 字数大于1时 组词
        if( WordCanContinueSplit(ime_input_split) )
        {
            PinyinResultInsertCombine(DB, save_field_array, search_result)
        }

        ; 插入前面个拼音所能组成的候选词
        PinyinResultInsertWords(DB, ime_input_split, search_result)

        ; 逐码提示 联想
        ; PinyinResultInsertAssociate(DB, search_result, ime_input_split)

        ; 插入字部分
        PinyinResultInsertSingleWord(DB, search_result, ime_input_split)

        ; 更新辅助码
        PinyinResultUpdateRadical(search_result)

        ; 超级简拼 显示 4 字及以上简拼候选
        PinyinResultInsertSimpleSpell(DB, search_result, ime_orgin_input)

        ; 隐藏词频低于 0 的词条，仅在无其他候选项的时候出现
        PinyinResultHideZeroWeight(search_result)


        PinyinResultRemoveZeroIndex(search_result)
    }
    ; [
    ;     ; -1 , 0         , 1
    ;     ["wo", "pinyin|1", "wo", "我", "30233", "30233"]
    ;     ["wo", "pinyin|2", "wo", "窝", "30219", "30233"]
    ;     ...
    ; ]
    return search_result
}
