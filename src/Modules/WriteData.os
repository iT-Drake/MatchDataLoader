////////////////////////////////////////////////////////////////////////
//
// Utility unit for writing data into .CSV files or formatted text
//
////////////////////////////////////////////////////////////////////////

#Region Public

Procedure ToCSV(FileName, ValueTable, Delimiter = ",") Export
	TextWriter = New TextWriter(FileName, TextEncoding.UTF8);
	Columns = ColumnsToString(ValueTable, Delimiter);
	TextWriter.WriteLine(Columns);

	For Each Item In ValueTable Do
		Line = ItemToString(Item, Delimiter);
		TextWriter.WriteLine(Line);
	EndDo;

	TextWriter.Close();
EndProcedure

Procedure ToFormattedText(FileName, ValueTable) Export
	ColumnWidth = ColumnWidth(ValueTable);
	TextWriter = New TextWriter(FileName, TextEncoding.UTF8);

	Array = New Array;
	For Each Column In ValueTable.Columns Do
		Value = SetStringToSize(Column.Name, ColumnWidth[Column.Name] + 1);
		Array.Add(Value);
	EndDo;
	TextWriter.WriteLine(StrConcat(Array));

	For Each Item In ValueTable Do
		Array.Clear();
		For Each Column In ValueTable.Columns Do
			Value = SetStringToSize(Item[Column.Name], ColumnWidth[Column.Name] + 1);
			Array.Add(Value);
		EndDo;
		TextWriter.WriteLine(StrConcat(Array));
	EndDo;

	TextWriter.Close();
EndProcedure

#EndRegion

#Region Private

Function ColumnsToString(ValueTable, Delimiter)
	Array = New Array;
	For Each Column In ValueTable.Columns Do
		Array.Add(Column.Name);
	EndDo;
	Line = StrConcat(Array, Delimiter);

	Return Line;
EndFunction

Function ItemToString(Item, Delimiter)
	LastColumn = Item.Owner().Columns.Count() - 1;
	Array = New Array;
	For i = 0 To LastColumn Do
		Array.Add(Item[i]);
	EndDo;
	Line = StrConcat(Array, Delimiter);

	Return Line;
EndFunction

Function StringOfSpaces(Size)
	Array = New Array(Size);
	For i = 0 To Array.UBound() Do
		Array[i] = " ";
	EndDo;

	Return StrConcat(Array);
EndFunction

Function ColumnWidth(ValueTable)
	Result = New Structure;
	For Each Column In ValueTable.Columns Do
		Result.Insert(Column.Name, StrLen(Column.Name));
	EndDo;

	For Each Item In ValueTable Do
		For Each Column In ValueTable.Columns Do
			Width = StrLen(String(Item[Column.Name]));
			If Width > Result[Column.Name] Then
				Result.Insert(Column.Name, Width);
			EndIf;
		EndDo;
	EndDo;

	Return Result;
EndFunction

Function SetStringToSize(String, Size);
	StringOfSpaces = StringOfSpaces(Size);
	Return Left(StrTemplate("%1%2", String, StringOfSpaces), Size);
EndFunction

#EndRegion