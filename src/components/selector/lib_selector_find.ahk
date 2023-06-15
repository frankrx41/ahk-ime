;*******************************************************************************
;
SelectorCheckTotalWeight(candidate, left_split_index, left_length, right_length, ByRef left_word)
{
    left_select_index   := CandidateFindMaxLengthSelectIndex(candidate, left_split_index, left_length)
    left_word_length    := CandidateGetWordLength(candidate, left_split_index, left_select_index)
    left_word           := CandidateGetWord(candidate, left_split_index, left_select_index)
    if( left_word_length != left_length ) {
        return 0
    }
    left_weight := CandidateGetWeight(candidate, left_split_index, left_select_index)

    ImeProfilerBegin()

    right_split_index   := left_split_index+A_Index
    if( right_split_index > candidate.Length() || right_length == 0 ){
        right_weight := 0
        right_word := ""
        right_word_length := 0
    } else {
        max_weight := 0
        right_select_index := 0
        right_word_length := 0
        loop, % right_length
        {
            find_word_length := A_Index
            found_select_index := CandidateFindMaxLengthSelectIndex(candidate, right_split_index, find_word_length)
            if( found_select_index != 0 )
            {
                found_word_length := CandidateGetWordLength(candidate, right_split_index, found_select_index)
                if( found_word_length < find_word_length )
                {
                    break
                }
                found_weight := CandidateGetWeight(candidate, right_split_index, found_select_index)
                if( max_weight <= found_weight ) {
                    max_weight := found_weight
                    right_select_index := found_select_index
                    right_word_length := find_word_length
                }
            }
        }
        Assert(right_select_index != 0, "", false)
        right_weight := max_weight
        right_word  := CandidateGetWord(candidate, right_split_index, right_select_index)
    }
    total_weight := left_weight + right_weight
    profile_text := Format("[{}{}/{}, {}{}/{}]", left_word, left_word_length, left_length, right_word, right_word_length, right_length)
    profile_text .= Format("{:.1f} + {:.1f} = {:.1f} ({})", left_weight, right_weight, total_weight, left_word)
    ImeProfilerEnd(profile_text)

    return total_weight
}

SelectorFindGraceResultIndex(candidate, split_index, max_length)
{
    max_weight := 0
    ; loop_length := Min(max_length, CandidateGetMaxWordLength(candidate, split_index))
    loop_length := max_length
    better_length := max_length
    ImeProfilerBegin()
    select_word := "N/A"
    loop, % loop_length
    {
        test_max_length := SplitterResultGetHopeLength(CandidateGetSplittedList(candidate)[split_index+A_Index])
        if( test_max_length > 0 )
        {
            weight := SelectorCheckTotalWeight(candidate, split_index, A_Index, test_max_length, word)

            if( max_weight <= weight ) {
                max_weight := weight
                better_length := A_Index
                select_word := word
            }
        }
    }
    select_index := CandidateFindWordSelectIndex(candidate, split_index, select_word)
    profile_text := max_length ", " better_length ", " select_index ", " select_word ": """ CandidateGetWord(candidate, split_index, select_index) """"
    ImeProfilerEnd(profile_text)
    return select_index
}