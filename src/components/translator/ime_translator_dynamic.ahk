TranslatorDynamicClear()
{
    global translator_history_weight := {}  ; {[0]: total_index, "bu4shou3": [[0]:1, "部首", "不守"] }
    translator_history_weight[0] := 0
}


;*******************************************************************************
;
PinyinCheckMatch(check_pinyin, complete_pinyin)
{
    check_pinyin_index := 1
    last_check_char := ""
    loop, Parse, complete_pinyin
    {
        check_char := SubStr(check_pinyin, check_pinyin_index, 1)
        if( IsTone(A_LoopField) ){
            if( check_char == "0" || A_LoopField == check_char ){
                check_pinyin_index += 1
                last_check_char := check_char
            }
            else
            if( A_LoopField != check_char ){
                return false
            }
        }
        else
        if( A_LoopField ){
            if( check_char == "%" || A_LoopField == check_char ) {
                check_pinyin_index += 1
                last_check_char := check_char
            }
            else
            if( A_LoopField != check_char && last_check_char != "%" ){
                return false
            }
        }
    }
    return check_pinyin_index-1 == StrLen(check_pinyin)
}


;*******************************************************************************
;
TranslatorDynamicMark(pinyin, word)
{
    local
    global translator_history_weight

    Assert(pinyin)

    translator_history_weight[0] += 1
    if( !translator_history_weight.HasKey(pinyin) ){
        translator_history_weight[pinyin] := []
        translator_history_weight[pinyin, 0] := 0
    }
    loop, % translator_history_weight[pinyin].Length() {
        if( translator_history_weight[pinyin, A_Index] == word ){
            translator_history_weight[pinyin].RemoveAt(A_Index, 1)
            break
        }
    }
    translator_history_weight[pinyin].Push(word)
    translator_history_weight[pinyin, 0] := translator_history_weight[0]
}
