; Key`tvalue1 value2
; Ignore string start with ";"
ReadFileToTable(file_name)
{
    FileRead, file_content, %file_name%
    return ReadStringToTable(file_content)
}

ReadStringToValueData(string, mark1, mark2)
{
    if( InStr(string, mark2) )
    {
        data_array := StrSplit(string, mark1)
        data := []
        for index, element in data_array
        {
            if( element )
            {
                ; data.Push(CopyObj(ReadStringToValueData(element)))
                data.Push(StrSplit(element, mark2))
            }
        }
        return data
    }
    else
    {
        return StrSplit(string, mark1)
    }
}

ReadStringToTable(file_content, mark0:="`t", mark1:=",", mark2:=" ")
{
    data_table := {}
    Loop, Parse, file_content, `n, `r
    {
        line_string := A_LoopField
        line_string := RegExReplace(line_string, "\s*;.*")
        if( line_string )
        {
            ; line_string := RegExReplace(line_string, " +", " ")
            ; Split each line by the tab character
            line_arr := StrSplit(line_string, mark0,, 2)
            value_data := ReadStringToValueData(line_arr[2], mark1, mark2)
            ; data_table[line_arr[1]] := CopyObj(value_data)
            data_table[line_arr[1]] := value_data
        }
    }
    Assert(data_table.Count() != 0)

    return data_table
}
