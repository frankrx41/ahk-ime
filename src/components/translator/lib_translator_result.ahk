;*******************************************************************************
; translator_result := []
;   [1]: "wo3"      ; legacy pinyin (SQL)
;   [2]: "我"       ; word value    (SQL)
;   [3]: 30233      ; weight        (SQL)
;   [4]: ""         ; comment       (SQL)
;   [5]: 1          ; word length   (In some case, "guamo" can has result "谷阿莫", but it only taken 2 length)
;   [6]: false      ; traditional:  0 false, 1 trad, 2 auto trad
;   [7]: 0          ; top position: 0 no top, 1 1st top, 2 2nd top
;   [8]: false      ; diable
;
TranslatorResultGetLegacyPinyin(ByRef translate_result) {
    return translate_result[1]
}
TranslatorResultGetWord(ByRef translate_result) {
    return translate_result[2]
}
TranslatorResultGetWeight(ByRef translate_result) {
    return translate_result[3]
}
TranslatorResultGetComment(ByRef translate_result) {
    return translate_result[4]
}
TranslatorResultGetWordLength(ByRef translate_result) {
    return translate_result[5]
}
TranslatorResultGetTraditionalLevel(ByRef translate_result) {
    return translate_result[6]
}
TranslatorResultGetTopLevel(ByRef translate_result) {
    return translate_result[7]
}
TranslatorResultIsDisable(ByRef translate_result) {
    return translate_result[8]
}

TranslatorResultSetWordLength(ByRef translate_result, length) {
    translate_result[5] := length
}

TranslatorResultAppendComment(ByRef translate_result, comment) {
    translate_result[4] .= comment
}

TranslatorResultAddMatchLevel(ByRef translate_result, match_level) {
    ; 0: no_match, 1~100: match_level
    translate_result[4] := match_level "%"
}

;*******************************************************************************
;
TranslatorResultMake(pinyin, word, weight, comment, word_length)
{
    return [pinyin, word, weight, comment, word_length, 0, 0, false]
}

TranslatorResultMakeDisable(pinyin, word, comment:="N/A")
{
    translate_result := TranslatorResultMake(pinyin, word, 0, comment, 1)
    translate_result[8] := true
    return translate_result
}

TranslatorResultMakeTraditional(ByRef translate_result, tranditional_word, trand_level)
{
    tranditional_translate_result := CopyObj(translate_result)
    tranditional_translate_result[2] := tranditional_word
    tranditional_translate_result[6] := trand_level
    return tranditional_translate_result
}

TranslatorResultMakeTop(ByRef translate_result, weight, top_level:=1)
{
    top_translate_result := CopyObj(translate_result)
    top_translate_result[3] := weight
    top_translate_result[7] := true
    return top_translate_result
}

TranslatorResultMakeError()
{
    return TranslatorResultMakeDisable("", "Error")
}

;*******************************************************************************
; Sort
TranslatorResultListSortByWeight(ByRef translate_result_list)
{
    ; TODO: 换成更高效且稳定的函数
    return ObjectSort(translate_result_list, 3,, true)
}
