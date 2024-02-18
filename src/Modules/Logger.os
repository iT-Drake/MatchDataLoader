////////////////////////////////////////////////////////////////////////
//
// Logos library wrapper
//
////////////////////////////////////////////////////////////////////////

#Use logos

Var Log;
Var Level Export;

////////////////////////////////////////////////////////////////////////
// Public methods
////////////////////////////////////////////////////////////////////////

#Region Public

Procedure Initialize(LogName) Export
	Log = Логирование.ПолучитьЛог(LogName);
	Level = LogLevels();
EndProcedure

Procedure SetLogLevel(LogLevel) Export
	Log.УстановитьУровень(LogLevel);
EndProcedure

Procedure Information(Message, Parameter1 = Undefined, Parameter2 = Undefined, Parameter3 = Undefined,
	Parameter4 = Undefined, Parameter5 = Undefined, Parameter6 = Undefined) Export
	Log.Информация(Message, Parameter1, Parameter2, Parameter3, Parameter4, Parameter5, Parameter6);
EndProcedure

Procedure Warning(Message, Parameter1 = Undefined, Parameter2 = Undefined, Parameter3 = Undefined,
	Parameter4 = Undefined, Parameter5 = Undefined, Parameter6 = Undefined) Export
	Log.Предупреждение(Message, Parameter1, Parameter2, Parameter3, Parameter4, Parameter5, Parameter6);
EndProcedure

Procedure Error(Message, Parameter1 = Undefined, Parameter2 = Undefined, Parameter3 = Undefined,
	Parameter4 = Undefined, Parameter5 = Undefined, Parameter6 = Undefined) Export
	Log.Ошибка(Message, Parameter1, Parameter2, Parameter3, Parameter4, Parameter5, Parameter6);
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

#EndRegion
