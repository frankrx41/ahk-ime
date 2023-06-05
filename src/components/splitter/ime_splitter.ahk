ImeSplitterInputString(input_string)
{
    if( ImeLanguageIsChinese() ){
        scheme_simple := ImeSchemeIsPinyinSimple()
        scheme_double := ImeSchemeIsPinyinDouble()
        splitted_list := PinyinSplitterInputString(input_string, scheme_simple, scheme_double)
    } else
    if( ImeLanguageIsJapanese() ) {
        splitted_list := GojuonSplitterInputString(input_string)
    }
    return splitted_list
}
