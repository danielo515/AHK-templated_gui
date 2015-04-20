;
; AutoHotkey Version: 1.x
; Language:       English
; Platform:       Win9x/NT
; Author:         Danielo Rodriguez www.github.com/danielo515
;
; Script Function:
;	Script that builds up a gui based on a template. Template process depens also on the template
;

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

template=
(join`n
/Date:
New Alarm:
Original Alarm:
Ticket:
\Issue:|Filters' reorganization||Avoid SPAM to NOC
\Action:|DELETED||Filtered
Responsible:|
\Notes:|Requested By Juan Camilo Mendez||Requested By NOC
\Perm or Temp:|PERM||TEMP
)
fieldTokens := "/\_" ;thokens should match types
fieldTypes := {"\":Func("addComboBox"),"/":Func("addDateField"),"_":Func("addMultiLine")}
fieldProcessors := {"New Alarm":Func("processTicket"),"Original Alarm":Func("processTicket"),"Date":Func("processDate"),"_":Func("addMultiLine")}

Loop, parse, template, `n
{
	Question:=A_LoopField
	fieldtype := SubStr(Question,1,1)
	
	If InStr(fieldTokens,fieldType)
		Question := SubStr(Question,2)
	
	If InStr(Question,"|")
	{
		If % fieldtype = "\" ;case of drop downs
		{
			value := SubStr(Question,InStr(Question,"|")+1) ; from pipe en adelante
			Question:= RegExReplace(Question,"\|.*") ;remove everyting but question
		}
		Else
		{
			Value:=StrSplit(Question,"|").2
			Question:=StrSplit(Question,"|").1
		}
	}
	
	Gui, Add, Text,, % "&" A_Index " - " Question
	
     If fieldtypes[fieldType]
		fieldtypes[fieldType].call("Input" . A_Index, value)
	Else
		Gui, Add, Edit, w200 vInput%A_Index% w400, % value
	
     question:="",value:=""
}
Gui, Add, Button, gSave w200, &OK
Gui, Add, Button, xp+210 yp gGuiClose w200, &Close
Gui, +AlwaysOnTop
Gui, Show
Return

Save:
Gui, Submit, Hide
result := [""]
global separator := A_Tab
Loop, parse, template, `n
{
	Question := RegExReplace(A_LoopField,"^\W|:.*")
     if(fieldProcessors[Question])	
		result := fieldProcessors[Question].call(result, Input%A_Index%, Question,separator)
	else
		result := defaultProcessor(result, Input%A_Index%, Question,separator)
	
}
output := "`n".Join(result)
clipboard = %output%
saverCSV(output)
ExitApp
Return

GuiClose:
ExitApp

defaultProcessor(composition,value,key:=0,sep:=","){
	result := []
	Loop % composition.MaxIndex()
	{
		result.Insert(composition[A_Index] . sep . value)
	}
	;MsgBox, % "Default processor processing `n"value " -- "result[1] " " key
	return result
}

processDate(composition,value,key:=0,sep:=","){
	FormatTime, formatted, value, dd/MM/yyyy
	return defaultProcessor(composition,formatted,key,sep)
}

processTicket(composition,value,key:=0,sep:=","){
	items := StrSplit(value," ")
	result := []
	
	
	
	if( items.maxindex() > composition.maxindex() )
		big := items
	else
		big := composition
	
	i := 1
	j := 1
	for, key, val in big
	{   
		result.Insert(composition[i] . sep . items[j])
		i := ++i > composition.maxindex() ? 1 : i++
		j := ++j > items.maxindex() ? 1 : j++
	}
	
	; MsgBox, % "processing`n " key " -" items[1] "-`n" ".".Join(result)
	return result
}

Join(s,p*){
	static _:="".base.Join:=Func("Join")
	for k,v in p
	{
		if isobject(v)
			for k2, v2 in v
				o.=s v2
		else
			o.=s v
	}
	return SubStr(o,StrLen(s)+1)
}

saverCSV(data,filename:="filters"){
	global separator
    StringReplace, csvData, data,%separator%,`,,All
	
	csvData := RegExReplace(csvData,"m`n)^\W+")
	saveToFile(csvData,filename,".csv")
	return
}
saveToFile(data,filename,extension:="txt")
{
    file = %filename%%extension%
    IfExist,%file%
        data = `n%data%
    fileappend,%data%,*%file%
    return
}

addMultiLine(inputName,value){
	global
	Gui, Add, Edit, v%inputName% w400 R5, % value	
}

addDateField(inputName,value:=0){
	global
	Gui, Add, DateTime, v%inputName%, MM/dd/yy	
}

addComboBox(inputName,value){
	global
	Gui, Add, ComboBox, v%inputName% w400 , % value	
}