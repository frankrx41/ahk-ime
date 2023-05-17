;*******************************************************************************
; translator_result := []
;   [1]: "wo3"      ; legacy pinyin
;   [2]: "我"       ; word value
;   [3]: 30233      ; weight
;   [4]: ""         ; comment
;   [5]: 1          ; word length
;   [6]: 1          ; input pinyin
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
TranslatorResultGetInputPinyin(ByRef translate_result) {
    return translate_result[6]
}

TranslatorResultSetWordLength(ByRef translate_result, length) {
    translate_result[5] := length
}

;*******************************************************************************
;
TranslatorResultMake(pinyin, word, weight, comment, word_length, input_pinyin)
{
    return [pinyin, word, weight, comment, word_length, input_pinyin]
}

TranslatorResultMakeError()
{
    return TranslatorResultMake("", "", 0, "Error", 1, "")
}

;*******************************************************************************
; Sort
TranslatorResultListSortByWeight(ByRef translate_result_list)
{
    ; TODO: 换成更高效且稳定的函数
    return ObjectSort(translate_result_list, 3,, true)
}
