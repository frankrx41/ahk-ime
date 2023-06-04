ImeSplitterInputString(input_string)
{
    if( ImeLanguageIsChinese() ){
        splitted_list := PinyinSplitterInputString(input_string)
    } else
    if( ImeLanguageIsJapanese() ) {
        splitted_list := GojuonSplitterInputString(input_string)
    }
    return splitted_list
}
