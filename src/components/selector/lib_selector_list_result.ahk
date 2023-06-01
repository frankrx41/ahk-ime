;*******************************************************************************
;
SelectorResultUnLockFrontWords(ByRef selector_result_list, split_index)
{
    local
    ; Find if any prev result length include this
    test_length := 0
    loop
    {
        test_index := A_Index
        if( test_index >= split_index ){
            break
        }
        if( SelectorResultIsSelectLock(selector_result_list[test_index]) )
        {
            if( test_length + SelectorResultGetLockLength(selector_result_list[test_index]) >= split_index ){
                SelectorResultUnLockWord(selector_result_list[test_index])
                break
            }
        }
        else {
            test_length += 1
        }
    }
}

SelectorResultUnLockAfterWords(ByRef selector_result_list, split_index)
{
    local
    loop % selector_result_list.Length()
    {
        test_index := A_Index
        if( test_index > split_index )
        {
            SelectorResultUnLockWord(selector_result_list[test_index])
        }
    }
}
