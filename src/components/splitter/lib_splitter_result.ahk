;*******************************************************************************
; splitter_result
;   [1]:
;       [1]: "wo"       ; 拼音
;       [2]: 3          ; 音调 0 任意音，1~5 具体音
;       [3]: "S"        ; 辅助码
;       [4]: 1          ; 原始字符串中开始的位置
;       [5]: 3          ; 原始字符串中结束的位置
;       [6]: true       ; 需要翻译该词条
;       [7]: 1          ; 期待单词长度
;       [8]: true       ; 是完整的单词 (拼音末尾不是 %)
;
SplitterResultMake(pinyin, tone, radical, start_pos, end_pos, need_translate:=true, hope_len:=1)
{
    is_completed := SubStr(pinyin, 0, 1) != "%"
    return [pinyin, tone, radical, start_pos, end_pos, need_translate, hope_len, is_completed]
}

SplitterResultIsAutoSymbol(splitter_result)
{
    return SplitterResultGetPinyin(splitter_result) == "%%"
}

;*******************************************************************************
;
SplitterResultGetPinyin(splitter_result) {
    return splitter_result[1]
}
SplitterResultGetTone(splitter_result) {
    return splitter_result[2]
}
SplitterResultGetRadical(splitter_result) {
    return splitter_result[3]
}
SplitterResultGetStartPos(splitter_result) {
    return splitter_result[4]
}
SplitterResultGetEndPos(splitter_result) {
    return splitter_result[5]
}
SplitterResultNeedTranslate(splitter_result) {
    return splitter_result[6]
}
SplitterResultGetHopeLength(splitter_result) {
    return splitter_result[7]
}
SplitterResultIsCompleted(splitter_result) {
    return splitter_result[8]
}
