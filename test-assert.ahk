#Include, ime_func.ahk
#Include, ime_assert.ahk

foo1()
return

foo1()
{
  foo2()
}
foo2()
{
  foo3()
}
foo3()
{
  foo4()
}
foo4()
{
  foo5()
}
foo5()
{
  foo6()
}
foo6()
{
  foo7()
}

foo7()
{
    Assert(0, "Some debug info")
    Assert(0, "Some debug info", 0)
    Assert(0, "Some debug info", 0)
    Assert(0, "Some debug info", 0)
    Assert(0, "Some debug info", 0)
    Assert(0, "Another debug info", 1, 0)
}