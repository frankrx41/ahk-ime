; TODO: give a better name
PinyinProcess(ByRef DB, input_spilt_string)
{
    local
    spilt_string := input_spilt_string
    begin := A_TickCount

    loop
    {
        if( !spilt_string ){
            break
        }
        if (A_TickCount - begin > 50 && !Mod(A_Index, 20)){
            Assert(0, "Forward timeout")
            break
        }
        
        ; "wo'xi'huan'ni" -> ["wo'xi'huan'ni"] -> ["wo'xi'huan" + "ni"] -> ["wo'xi" + "huan'ni"] -> ["wo" + "xi'huan'ni"]
        index := SplitWordGetWordCount(spilt_string)
        loop
        {
            if( index >= 1 )
            {
                input_left := SplitWordTrimMaxCount(spilt_string, index)
                Assert( input_left )
                PinyinHistoryUpdateKey(DB, input_left)
                if( PinyinHistoryHasKey(input_left) && PinyinHistoryHasResult(input_left) ){
                    spilt_string := SubStr(spilt_string, StrLen(input_left)+1)
                    break
                } else {
                    index -= 1
                }
            }
            else
            {
                ; e.g. "va"
                spilt_string := ""
                break
            }
        }
    }
}
