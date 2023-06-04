ImeSplitterInputString(input_string)
{
    if( ImeLanguageIsChinese() ){
        scheme_simple := ImeSchemeIsPinyinSimple()
        splitted_list := PinyinSplitterInputString(input_string, scheme_simple)
    } else
    if( ImeLanguageIsJapanese() ) {
        splitted_list := GojuonSplitterInputString(input_string)
    }
    return splitted_list
}
