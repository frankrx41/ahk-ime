;*******************************************************************************
;
SelectorCheckTotalWeight(candidate, left_split_index, left_length, right_length, ByRef left_word)
{
    left_select_index   := CandidateFindMaxLengthSelectIndex(candidate, left_split_index, left_length, true, left_weight)
    left_word_length    := CandidateGetWordLength(candidate, left_split_index, left_select_index)
    left_word           := CandidateGetWord(candidate, left_split_index, left_select_index)
    if( left_word_length != left_length ) {
        return 0
    }

    ImeProfilerBegin()

    right_split_index   := left_split_index+A_Index
    if( right_split_index > candidate.Length() || right_length == 0 ){
        right_weight := 28000
        right_word := ""
        right_word_length := 0
    } else {
        max_weight := 0
        right_select_index := 0
        right_word_length := 0
        loop, % right_length
        {
            test_select_index := CandidateFindMaxLengthSelectIndex(candidate, right_split_index, A_Index, false, weight)
            if(test_select_index != 0)
            {
                if( CandidateGetWordLength(candidate, right_split_index, test_select_index) < A_Index )
                {
                    Assert(right_select_index != 0, , false)
                    break
                }
                if( max_weight <= weight ) {
                    max_weight := weight
                    right_select_index := test_select_index
                    right_word_length := A_Index
                }
            }
        }
        Assert(right_select_index != 0, , false)
        ; right_word_length := CandidateGetWordLength(candidate, right_split_index, right_select_index)
        right_weight := max_weight
        right_word  := CandidateGetWord(candidate, right_split_index, right_select_index)
    }
    ; profile_text .= "[" left_word "(" left_split_index ") ," right_word "(" right_split_index ") ] " left_weight " + " right_weight " = " left_weight + right_weight
    total_weight := left_weight + right_weight
    ; return_weight := total_weight
    ; profile_text .= "" left_word left_word_length "," right_word right_word_length "] " left_weight " + " right_weight " = " total_weight
    profile_text := Format("[{}{}, {}{}] {:.2f} + {:.2f} = {:.2f} ({})", left_word, left_word_length, right_word, right_word_length, left_weight, right_weight, total_weight, left_word)
    ImeProfilerEnd(profile_text)

    return total_weight
}

SelectorFindGraceResultIndex(candidate, split_index, max_length)
{
    max_weight := 0
    loop_length := Min(max_length, CandidateGetMaxWordLength(candidate, split_index))
    better_length := max_length
    ImeProfilerBegin()
    select_word := "N/A"
    loop, % loop_length
    {
        weight := SelectorCheckTotalWeight(candidate, split_index, A_Index, max_length-A_Index, word)

        if( max_weight <= weight ) {
            max_weight := weight
            better_length := A_Index
            select_word := word
        }
    }
    select_index := CandidateFindWordSelectIndex(candidate, split_index, select_word)
    profile_text := better_length ", " select_index ", " select_word ": """ CandidateGetWord(candidate, split_index, select_index) """"
    ImeProfilerEnd(profile_text)
    return select_index
}