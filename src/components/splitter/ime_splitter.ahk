ImeSplitterInputString(input_string)
{
    if( ImeLanguageIsChinese() ){
        scheme_simple := ImeSchemeIsPinyinSimple()
        scheme_double := ImeSchemeIsPinyinDouble()
        scheme_bopomofo := ImeSchemeIsPinyinBopomofo()
        splitted_list := PinyinSplitterInputString(input_string, scheme_simple, scheme_double, scheme_bopomofo)
    } else
    if( ImeLanguageIsJapanese() ) {
        splitted_list := GojuonSplitterInputString(input_string)
    }
    return splitted_list
}
