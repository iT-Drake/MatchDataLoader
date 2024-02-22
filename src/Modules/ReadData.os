////////////////////////////////////////////////////////////////////////
//
// Utility unit for reading data from .CSV files
//
////////////////////////////////////////////////////////////////////////

#Region Public

Function FromCSV(FileName, Delimiter = ",", ContainsHeaders = True) Export
	TextReader = New TextReader(FileName, TextEncoding.UTF8);
	
	If ContainsHeaders Then
		Result = ReadFileIntoTable(TextReader, Delimiter);
	Else
		Result = ReadFileIntoArray(TextReader, Delimiter);
	EndIf;

	TextReader.Close();

	Return Result;
EndFunction

Function FromString(String, Delimiter = ",") Export
	Return SplitValues(String, Delimiter);
EndFunction

#EndRegion

#Region Private

Function ReadFileIntoTable(TextReader, Delimiter)
	Line = "";
	While Line <> Undefined AND IsBlankString(Line) Do
		Line = TextReader.ReadLine();
	EndDo;
	
	Result = New ValueTable;
	If Line = Undefined Then
		Return Result;
	EndIf;

	Columns = SplitValues(Line, Delimiter, False);
	For Each Column In Columns Do
		Try
			Result.Columns.Add(Column);
		Except
			Raise StrTemplate("Error reading file. Unsupported column name: %1", Column);
		EndTry;
	EndDo;

	Line = TextReader.ReadLine();
	While Line <> Undefined Do
		If IsBlankString(Line) Then
			Line = TextReader.ReadLine();
			Continue;
		EndIf;

		Item = Result.Add();
		Values = SplitValues(Line, Delimiter);
		For i = 0 To Min(Values.UBound(), Columns.UBound()) Do
			Item[i] = Values[i];
		EndDo;

		Line = TextReader.ReadLine();
	EndDo;

	Return Result;
EndFunction

Function ReadFileIntoArray(TextReader, Delimiter)
	Line = "";
	While Line <> Undefined AND IsBlankString(Line) Do
		Line = TextReader.ReadLine();
	EndDo;
	
	Result = New Array;
	If Line = Undefined Then
		Return Result;
	EndIf;

	Values = SplitValues(Line, Delimiter);
	Result.Add(Values);

	Line = TextReader.ReadLine();
	While Line <> Undefined Do
		If IsBlankString(Line) Then
			Line = TextReader.ReadLine();
			Continue;
		EndIf;

		Values = SplitValues(Line, Delimiter);
		Result.Add(Values);

		Line = TextReader.ReadLine();
	EndDo;

	Return Result;
EndFunction

Function SplitValues(String, Delimiter, IncludeEmpty = True)
	Return StrSplit(String, Delimiter, IncludeEmpty);
EndFunction

#EndRegion