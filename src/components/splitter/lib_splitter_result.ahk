;*******************************************************************************
; splitter_result
;   [1]:
;       [pinyin]: "wo"          ; 拼音
;       [tone]: 3               ; 音调 0 任意音，1~5 具体音
;       [radical]: "S"          ; 辅助码
;       [pos_start]: 1          ; 原始字符串中开始的位置
;       [pos_end]: 3            ; 原始字符串中结束的位置
;       [need_translate]: true  ; 需要翻译该词条
;       [hope_length]: 1        ; 期待单词长度
;       [is_complete]: true     ; 是完整的单词 (拼音末尾不是 %)
;
SplitterResultMake(pinyin, tone, radical, start_pos, end_pos, need_translate:=true, hope_len:=1)
{
    is_completed := SubStr(pinyin, 0, 1) != "%"
    splitter_result := {}
    splitter_result["pinyin"]       := pinyin
    splitter_result["tone"]         := tone
    splitter_result["radical"]      := radical
    splitter_result["pos_start"]    := start_pos
    splitter_result["pos_end"]      := end_pos
    splitter_result["need_translate"] := need_translate
    splitter_result["hope_length"]  := hope_len
    splitter_result["is_complete"]  := is_completed
    return splitter_result
}

SplitterResultIsAutoSymbol(splitter_result)
{
    return SplitterResultGetPinyin(splitter_result) == "%%"
}

;*******************************************************************************
;
SplitterResultGetPinyin(splitter_result) {
    return splitter_result["pinyin"]
}
SplitterResultGetTone(splitter_result) {
    return splitter_result["tone"]
}
SplitterResultGetRadical(splitter_result) {
    return splitter_result["radical"]
}
SplitterResultGetStartPos(splitter_result) {
    return splitter_result["pos_start"]
}
SplitterResultGetEndPos(splitter_result) {
    return splitter_result["pos_end"]
}
SplitterResultNeedTranslate(splitter_result) {
    return splitter_result["need_translate"]
}
SplitterResultGetHopeLength(splitter_result) {
    return splitter_result["hope_length"]
}
SplitterResultIsCompleted(splitter_result) {
    return splitter_result["is_complete"]
}
