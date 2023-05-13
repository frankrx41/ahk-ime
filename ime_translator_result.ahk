;*******************************************************************************
; translator_result := []
;   [1]: "wo3"      ; pinyin
;   [2]: "我"       ; value
;   [3]: 30233      ; weight
;   [4]: ""         ; comment
;   [5]: 1          ; word length
;
TranslatorResultGetPinyin(ByRef translate_result) {
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

;*******************************************************************************
;
TranslatorResultMake(pinyin, word, weight, comment, word_length)
{
    return [pinyin, word, weight, comment, word_length]
}

TranslatorResultMakeError()
{
    return TranslatorResultMake("", "", 0, "Error", 1)
}

;*******************************************************************************
; Sort
TranslatorResultListSortByWeight(ByRef translate_result_list)
{
    ; TODO: 换成更高效且稳定的函数
    return ObjectSort(translate_result_list, 3,, true)
}
