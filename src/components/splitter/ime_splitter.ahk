ImeSplitterInputString(input_string)
{
    if( ImeLanguageIsChinese() ){
        scheme_simple   := ImeSchemeIsPinyinSimple()
        scheme_bopomofo := ImeLanguageIsTraChinese() ? ImeSchemeIsPinyinBopomofo() : false
        scheme_double   := ImeLanguageIsSimChinese() ? ImeSchemeIsPinyinDouble() : false
        splitted_list := PinyinSplitterInputString(input_string, scheme_simple, scheme_double, scheme_bopomofo)
    } else
    if( ImeLanguageIsJapanese() ) {
        splitted_list := GojuonSplitterInputString(input_string)
    }
    return splitted_list
}
