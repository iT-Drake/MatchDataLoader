////////////////////////////////////////////////////////////////////////
//
// Basic logging tool
//
////////////////////////////////////////////////////////////////////////

#Use logos

Var CurrentLevel;
Var Level Export;

////////////////////////////////////////////////////////////////////////
// Public methods
////////////////////////////////////////////////////////////////////////

#Region Public

Procedure Initialize() Export
	Level = LogLevels();
EndProcedure

Procedure SetLogLevel(LogLevel) Export
	CurrentLevel = LogLevel;
EndProcedure

Procedure Information(Message, Parameter1 = Undefined, Parameter2 = Undefined, Parameter3 = Undefined,
	Parameter4 = Undefined, Parameter5 = Undefined, Parameter6 = Undefined) Export

	ShowMessage(Message, Level.Information, Parameter1, Parameter2, Parameter3, Parameter4, Parameter5, Parameter6);
EndProcedure

Procedure Warning(Message, Parameter1 = Undefined, Parameter2 = Undefined, Parameter3 = Undefined,
	Parameter4 = Undefined, Parameter5 = Undefined, Parameter6 = Undefined) Export

	ShowMessage(Message, Level.Warning, Parameter1, Parameter2, Parameter3, Parameter4, Parameter5, Parameter6);
EndProcedure

Procedure Error(Message, Parameter1 = Undefined, Parameter2 = Undefined, Parameter3 = Undefined,
	Parameter4 = Undefined, Parameter5 = Undefined, Parameter6 = Undefined) Export
	
	ShowMessage(Message, Level.Error, Parameter1, Parameter2, Parameter3, Parameter4, Parameter5, Parameter6);
EndProcedure

#EndRegion

////////////////////////////////////////////////////////////////////////
// Private methods
////////////////////////////////////////////////////////////////////////

#Region Private

Function LogLevels()
	Result = New Structure;
	Result.Insert("Information", 1);
	Result.Insert("Warning", 2);
	Result.Insert("Error", 3);
	
	Return Result;
EndFunction

Function LevelCaption(LogLevel)
	Result = New Map;
	Result.Insert(1, "INFORMATION");
	Result.Insert(2, "WARNING");
	Result.Insert(3, "ERROR");
	
	Return Result.Get(LogLevel);
EndFunction

Function FormatMessage(Message, Parameter1 = Undefined, Parameter2 = Undefined, Parameter3 = Undefined,
	Parameter4 = Undefined, Parameter5 = Undefined, Parameter6 = Undefined)
	
	FormattedMessage = ReplaceParameter(Message, Parameter6, 6);
	FormattedMessage = ReplaceParameter(FormattedMessage, Parameter5, 5);
	FormattedMessage = ReplaceParameter(FormattedMessage, Parameter4, 4);
	FormattedMessage = ReplaceParameter(FormattedMessage, Parameter3, 3);
	FormattedMessage = ReplaceParameter(FormattedMessage, Parameter2, 2);
	FormattedMessage = ReplaceParameter(FormattedMessage, Parameter1, 1);

	Return StrTemplate("%1 - %2", LevelCaption(CurrentLevel), FormattedMessage);
EndFunction

Function ReplaceParameter(Message, Value, ParameterNumber = 1)
	Parameter = "%" + ParameterNumber;
	If StrFind(Message, Parameter) = 0 Then
		Return Message;
	EndIf;

	Return StrReplace(Message, Parameter, String(Value));
EndFunction

Procedure ShowMessage(Val Message, Level, Parameter1, Parameter2, Parameter3, 	Parameter4,	Parameter5, Parameter6)
	If CurrentLevel > Level Then
		Return;
	EndIf;

	Message = FormatMessage(Message, Parameter1, Parameter2, Parameter3, Parameter4, Parameter5, Parameter6);
	Message(Message);
EndProcedure

#EndRegion
