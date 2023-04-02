SplittedInputGetWordCount(splitted_input)
{
    ; 包含 word + tone + word + ... 格式
    RegExReplace(splitted_input, "([012345])", "", count_use)
    return count_use
}

SplittedInputRemoveLastWord(splitted_input, repeat_count:=1)
{
    loop, % repeat_count
    {
        splitted_input := RegExReplace(splitted_input, "([^012345]+[012345])$")
    }
    return splitted_input
}
