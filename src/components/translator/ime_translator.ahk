ImeTranslateFindResult(splitter_result_list, auto_complete)
{
    if( ImeModeIsChinese() ){
        translate_result_list := PinyinTranslateFindResult(splitter_result_list, auto_complete)
    } else
    if( ImeModeIsJapanese() ) {
        translate_result_list := GojuonTranslateFindResult(splitter_result_list, auto_complete)
    }
    return translate_result_list
}
