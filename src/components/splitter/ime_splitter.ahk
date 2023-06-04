ImeSplitterInputString(input_string)
{
    if( ImeModeIsChinese() ){
        splitted_list := PinyinSplitterInputString(input_string)
    } else
    if( ImeModeIsJapanese() ) {
        splitted_list := GojuonSplitterInputString(input_string)
    }
    return splitted_list
}
