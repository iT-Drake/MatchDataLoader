////////////////////////////////////////////////////////////////////////
//
// Unit provides database connection and query execution functionality
//
////////////////////////////////////////////////////////////////////////

#Use sql

Var Connection;

////////////////////////////////////////////////////////////////////////
// Public methods
////////////////////////////////////////////////////////////////////////

#Region Public

Procedure Connect(DatabaseName = "") Export
	If NOT ValueIsFilled(DatabaseName) Then
		DatabaseName = ":memory:";
	EndIf;

	If NOT Connected() Then
		EstablishConnection(DatabaseName);
	Else
		If Connection.DbName <> DatabaseName Then
			Connection.Close();
			EstablishConnection(DatabaseName);
		EndIf;
	EndIf;
EndProcedure

Procedure Disconnect() Export
	If Connected() Then
		Connection.Close();
		Connection = Undefined;
	Endif;
EndProcedure

Function MatchExist(ID) Export
	Parameters = New Structure("MatchID", ID);
	Result = ExecuteQuery(QueryText.FindMatchID(), Parameters);

	Return Result.Count() > 0;
EndFunction

Function ExecuteCommand(Text, Parameters = Undefined) Export
	Query = NewQuery(Text);
	SetQueryParameters(Query, Parameters);

	Return Query.ExecuteCommand();
EndFunction

Function ExecuteQuery(Text, Parameters = Undefined) Export
	Query = NewQuery(Text);
	SetQueryParameters(Query, Parameters);

	Return Query.Execute().Unload();
EndFunction

Function ExecuteBatchQuery(BatchQuery) Export
	Result = New Structure;
	For Each Item In BatchQuery Do
		ValueTable = ExecuteQuery(Item.Value);
		Result.Insert(Item.Key, ValueTable);
	EndDo;

	Return Result;
EndFunction

#EndRegion

////////////////////////////////////////////////////////////////////////
// Private methods
////////////////////////////////////////////////////////////////////////

#Region Private

#Region Connection

Procedure EstablishConnection(DatabaseName)
	File = New File(DatabaseName);
	InitializationNeeded = Not File.Exist();

	Connection = New Connection();
	Connection.DBType = Connection.DBTypes.sqlite;
	Connection.DbName = DatabaseName;
	Connection.Open();

	If InitializationNeeded Then
		InitializeDatabase();
	EndIf;
EndProcedure

Function Connected()
	Return Connection <> Undefined;
EndFunction

Procedure CheckConnection()
	If NOT Connected() Then
		Raise "Not connected to a database. Use Connect() method first.";
	EndIf;
EndProcedure

#EndRegion

#Region Database

Procedure InitializeDatabase()
	CheckConnection();

	Query = NewQuery(QueryText.CreateTableMatchDetails());
	Query.ExecuteCommand();

	Query = NewQuery(QueryText.CreateTableUserDetails());
	Query.ExecuteCommand();

	Query = NewQuery(QueryText.CreateTableMechs());
	Query.ExecuteCommand();

	Query = NewQuery(QueryText.CreateTableTeamRosters());
	Query.ExecuteCommand();
EndProcedure

#EndRegion

#Region Queries

Function NewQuery(Text = "")
	CheckConnection();

	NewQuery = New Query();
	NewQuery.SetConnection(Connection);

	If NOT IsBlankString(Text) Then
		NewQuery.Text = Text;
	EndIf;

	Return NewQuery;
EndFunction

Procedure SetQueryParameters(Query, Parameters)
	If Parameters = Undefined Then
		Return;
	EndIf;

	For Each Parameter In Parameters Do
		Query.SetParameter(Parameter.Key, Parameter.Value);
	EndDo;
EndProcedure

#EndRegion

#EndRegion
