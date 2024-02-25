////////////////////////////////////////////////////////////////////////
//
// 1Connector library wrapper
//
////////////////////////////////////////////////////////////////////////

#Use 1connector

#Region Public

Function Get(URL, Parameters = Undefined) Export
	Return GetJSON(URL, Parameters);
EndFunction

#EndRegion

#Region Private

Function GetJSON(URL, Parameters = Undefined)
	Return КоннекторHTTP.Get(URL, Parameters).Json();
EndFunction

#EndRegion
