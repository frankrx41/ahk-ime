/****************************************************************************************************************************
 * Lib: JSON.ahk
 *     JSON Lib for AutoHotkey.
 * Version:
 *     v2.1.3 [updated 04/18/2016 (MM/DD/YYYY)]
 * License:
 *     WTFPL [http://wtfpl.net/]
 * Requirements:
 *     Latest version of AutoHotkey (v1.1+ or v2.0-a+)
 * Installation:
 *     Use #Include JSON.ahk or copy into a function Library folder and then
 *     use #Include <JSON>
 * Links:
 *     GitHub:     - https://github.com/cocobelgica/AutoHotkey-JSON
 *     Forum Topic - http://goo.gl/r0zI8t
 *     Email:      - cocobelgica <at> gmail <dot> com
 */


/**
 * Class: JSON
 *     The JSON object contains methods for parsing JSON and converting values
 *     to JSON. Callable - NO; Instantiable - YES; Subclassable - YES;
 *     Nestable(via #Include) - NO.
 * Methods:
 *     Load() - see relevant documentation before method definition header
 *     Dump() - see relevant documentation before method definition header
 */
class JSON
{
	/**
	 * Method: Load
	 *     Parses a JSON string into an AHK value
	 * Syntax:
	 *     value := JSON.Load( text [, reviver ] )
	 * Parameter(s):
	 *     value      [retval] - parsed value
	 *     text    [in, ByRef] - JSON formatted string
	 *     reviver   [in, opt] - function object, similar to JavaScript's
	 *                           JSON.parse() 'reviver' parameter
	 */
	class Load extends JSON.Functor
	{
		Call(self, ByRef text, reviver:="")
		{
			this.rev := IsObject(reviver) ? reviver : false
		; Object keys(and array indices) are temporarily stored in arrays so that
		; we can enumerate them in the order they appear in the document/text instead
		; of alphabetically. Skip If no reviver function is specIfied.
			this.keys := this.rev ? {} : false

			static quot := Chr(34), bashq := "\" . quot
				 , json_value := quot . "{[01234567890-tfn"
				 , json_value_or_array_closing := quot . "{[]01234567890-tfn"
				 , object_key_or_object_closing := quot . "}"

			_key := ""
			is_key := false
			root := {}
			stack := [root]
			next := json_value
			pos := 0

			while ((ch := SubStr(text, ++pos, 1)) != "") {
				If InStr(" `t`r`n", ch)
					continue
				If !InStr(next, ch, 1)
					this.ParseError(next, text, pos)

				holder := stack[1]
				is_array := holder.IsArray

				If InStr(",:", ch) {
					next := (is_key := !is_array && ch == ",") ? quot : json_value

				} Else If InStr("}]", ch) {
					ObjRemoveAt(stack, 1)
					next := stack[1]==root ? "" : stack[1].IsArray ? ",]" : ",}"

				} Else {
					If InStr("{[", ch) {
					; Check If Array() is overridden and If its return _value has
					; the 'IsArray' property. If so, Array() will be called normally,
					; otherwise, use a custom base object for arrays
						static json_array := Func("Array").IsBuiltIn || ![].IsArray ? {IsArray: true} : 0
					
					; sacrIfice readability for minor(actually negligible) performance gain
						(ch == "{")
							? ( is_key := true
							  , _value := {}
							  , next := object_key_or_object_closing )
						; ch == "["
							: ( _value := json_array ? new json_array : []
							  , next := json_value_or_array_closing )
						
						ObjInsertAt(stack, 1, _value)

						If (this.keys)
							this.keys[_value] := []
					
					} Else {
						If (ch == quot) {
							i := pos
							while (i := InStr(text, quot,, i+1)) {
								_value := StrReplace(SubStr(text, pos+1, i-pos-1), "\\", "\u005c")

								static tail := A_AhkVersion<"2" ? 0 : -1
								If (SubStr(_value, tail) != "\")
									break
							}

							If (!i)
								this.ParseError("'", text, pos)

							  _value := StrReplace(_value,  "\/",  "/")
							, _value := StrReplace(_value, bashq, quot)
							, _value := StrReplace(_value,  "\b", "`b")
							, _value := StrReplace(_value,  "\f", "`f")
							, _value := StrReplace(_value,  "\n", "`n")
							, _value := StrReplace(_value,  "\r", "`r")
							, _value := StrReplace(_value,  "\t", "`t")

							pos := i ; update pos
							
							i := 0
							while (i := InStr(_value, "\",, i+1)) {
								If !(SubStr(_value, i+1, 1) == "u")
									this.ParseError("\", text, pos - StrLen(SubStr(_value, i+1)))

								uffff := Abs("0x" . SubStr(_value, i+2, 4))
								If (A_IsUnicode || uffff < 0x100)
									_value := SubStr(_value, 1, i-1) . Chr(uffff) . SubStr(_value, i+6)
							}

							If (is_key) {
								_key := _value, next := ":"
								continue
							}
						
						} Else {
							_value := SubStr(text, pos, i := RegExMatch(text, "[\]\},\s]|$",, pos)-pos)

							static number := "number", integer :="integer"
							If _value is %number%
							{
								If _value is %integer%
									_value += 0
							}
							Else If (_value == "true" || _value == "false")
								_value := %_value% + 0
							Else If (_value == "null")
								_value := ""
							Else
							; we can do more here to pinpoint the actual culprit
							; but that's just too much extra work.
								this.ParseError(next, text, pos, i)

							pos += i-1
						}

						next := holder==root ? "" : is_array ? ",]" : ",}"
					} ; If InStr("{[", ch) { ... } Else

					is_array? _key := ObjPush(holder, _value) : holder[_key] := _value

					If (this.keys && this.keys.HasKey(holder))
						this.keys[holder].Push(_key)
				}
			
			} ; while ( ... )

			return this.rev ? this.Walk(root, "") : root[""]
		}

		ParseError(expect, ByRef text, pos, len:=1)
		{
			static quot := Chr(34), qurly := quot . "}"
			
			line := StrSplit(SubStr(text, 1, pos), "`n", "`r").Length()
			col := pos - InStr(text, "`n",, -(StrLen(text)-pos+1))
			msg := Format("{1}`n`nLine:`t{2}`nCol:`t{3}`nChar:`t{4}"
			,     (expect == "")     ? "Extra data"
				: (expect == "'")    ? "Unterminated string starting at"
				: (expect == "\")    ? "Invalid \escape"
				: (expect == ":")    ? "Expecting ':' delimiter"
				: (expect == quot)   ? "Expecting object _key enclosed in double quotes"
				: (expect == qurly)  ? "Expecting object _key enclosed in double quotes or object closing '}'"
				: (expect == ",}")   ? "Expecting ',' delimiter or object closing '}'"
				: (expect == ",]")   ? "Expecting ',' delimiter or array closing ']'"
				: InStr(expect, "]") ? "Expecting JSON _value or array closing ']'"
				:                      "Expecting JSON _value(string, number, true, false, null, object or array)"
			, line, col, pos)

			static offset := A_AhkVersion<"2" ? -3 : -4
			throw Exception(msg, offset, SubStr(text, pos, len))
		}

		Walk(holder, _key)
		{
			_value := holder[_key]
			If IsObject(_value) {
				for i, k in this.keys[_value] {
					; check If ObjHasKey(_value, k) ??
					v := this.Walk(_value, k)
					If (v != JSON.Undefined)
						_value[k] := v
					Else
						ObjDelete(_value, k)
				}
			}
			
			return this.rev.Call(holder, _key, _value)
		}
	}

	/**
	 * Method: Dump
	 *     Converts an AHK _value into a JSON string
	 * Syntax:
	 *     str := JSON.Dump( _value [, replacer, space ] )
	 * Parameter(s):
	 *     str        [retval] - JSON representation of an AHK _value
	 *     _value          [in] - any _value(object, string, number)
	 *     replacer  [in, opt] - function object, similar to JavaScript's
	 *                           JSON.stringIfy() 'replacer' parameter
	 *     space     [in, opt] - similar to JavaScript's JSON.stringIfy()
	 *                           'space' parameter
	 */
	class Dump extends JSON.Functor
	{
		Call(self, _value, replacer:="", space:="")
		{
			this.rep := IsObject(replacer) ? replacer : ""

			this.gap := ""
			If (space) {
				static integer := "integer"
				If space is %integer%
					Loop, % ((n := Abs(space))>10 ? 10 : n)
						this.gap .= " "
				Else
					this.gap := SubStr(space, 1, 10)

				this.indent := "`n"
			}

			return this.Str({"": _value}, "")
		}

		Str(holder, _key)
		{
			_value := holder[_key]

			If (this.rep)
				_value := this.rep.Call(holder, _key, ObjHasKey(holder, _key) ? _value : JSON.Undefined)

			If IsObject(_value) {
			; Check object type, skip serialization for other object types such as
			; ComObject, Func, BoundFunc, FileObject, RegExMatchObject, Property, etc.
				static type := A_AhkVersion<"2" ? "" : Func("Type")
				If (type ? type.Call(_value) == "Object" : ObjGetCapacity(_value) != "") {
					If (this.gap) {
						stepback := this.indent
						this.indent .= this.gap
					}

					is_array := _value.IsArray
				; Array() is not overridden, rollback to old method of
				; identIfying array-like objects. Due to the use of a for-loop
				; sparse arrays such as '[1,,3]' are detected as objects({}). 
					If (!is_array) {
						for i in _value
							is_array := i == A_Index
						until !is_array
					}

					str := ""
					If (is_array) {
						Loop, % _value.Length() {
							If (this.gap)
								str .= this.indent
							
							v := this.Str(_value, A_Index)
							str .= (v != "") ? v . "," : "null,"
						}
					} Else {
						colon := this.gap ? ": " : ":"
						for k in _value {
							v := this.Str(_value, k)
							If (v != "") {
								If (this.gap)
									str .= this.indent

								str .= this.Quote(k) . colon . v . ","
							}
						}
					}

					If (str != "") {
						str := RTrim(str, ",")
						If (this.gap)
							str .= stepback
					}

					If (this.gap)
						this.indent := stepback

					return is_array ? "[" . str . "]" : "{" . str . "}"
				}
			
			} Else ; is_number ? _value : "_value"
				return ObjGetCapacity([_value], 1)=="" ? _value : this.Quote(_value)
		}

		Quote(string)
		{
			static quot := Chr(34), bashq := "\" . quot

			If (string != "") {
				  string := StrReplace(string,  "\",  "\\")
				; , string := StrReplace(string,  "/",  "\/") ; optional in ECMAScript
				, string := StrReplace(string, quot, bashq)
				, string := StrReplace(string, "`b",  "\b")
				, string := StrReplace(string, "`f",  "\f")
				, string := StrReplace(string, "`n",  "\n")
				, string := StrReplace(string, "`r",  "\r")
				, string := StrReplace(string, "`t",  "\t")

				static rx_escapable := A_AhkVersion<"2" ? "O)[^\x20-\x7e]" : "[^\x20-\x7e]"
				; while RegExMatch(string, rx_escapable, m)
				; 	string := StrReplace(string, m._value, Format("\u{1:04x}", Ord(m._value)))
			}

			return quot . string . quot
		}
	}

	/**
	 * Property: Undefined
	 *     Proxy for 'undefined' type
	 * Syntax:
	 *     undefined := JSON.Undefined
	 * Remarks:
	 *     For use with reviver and replacer functions since AutoHotkey does not
	 *     have an 'undefined' type. Returning blank("") or 0 won't work since these
	 *     can't be distnguished from actual JSON values. This leaves us with objects.
	 *     Replacer() - the caller may return a non-serializable AHK objects such as
	 *     ComObject, Func, BoundFunc, FileObject, RegExMatchObject, and Property to
	 *     mimic the behavior of returning 'undefined' in JavaScript but for the sake
	 *     of code readability and convenience, it's better to do 'return JSON.Undefined'.
	 *     Internally, the property returns a ComObject with the variant type of VT_EMPTY.
	 */
	Undefined[]
	{
		get {
			static empty := {}, vt_empty := ComObject(0, &empty, 1)
			return vt_empty
		}
	}

	class Functor
	{
		__Call(method, ByRef arg, args*)
		{
		; When casting to Call(), use a new instance of the "function object"
		; so as to avoid directly storing the properties(used across sub-methods)
		; into the "function object" itself.
			If IsObject(method)
				return (new this).Call(method, arg, args*)
			Else If (method == "")
				return (new this).Call(arg, args*)
		}
	}
}