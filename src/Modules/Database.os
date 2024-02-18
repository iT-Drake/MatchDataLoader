////////////////////////////////////////////////////////////////////////
//
// Unit provides database connection and query execution functionality
//
////////////////////////////////////////////////////////////////////////

#Use sql

Var Connection;

#Region Public

////////////////////////////////////////////////////////////////////////
// Public methods
////////////////////////////////////////////////////////////////////////

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

#EndRegion

////////////////////////////////////////////////////////////////////////
// Private methods
////////////////////////////////////////////////////////////////////////

#Region Private

#Region Connection

Procedure EstablishConnection(DatabaseName)
	File = New File(DatabaseName);
	InitializationNeeded = Not File.Exist();

	Connection = New Соединение();
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

	Query = NewQuery(QueryTextCreateTableMatchDetails());
	Query.ExecuteCommand();

	Query = NewQuery(QueryTextCreateTableUserDetails());
	Query.ExecuteCommand();

	Query = NewQuery(QueryTextCreateTableMechs());
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

Function QueryTextCreateTableMatchDetails()
	Text = "CREATE TABLE MatchDetails (
	|	MatchID INTEGER PRIMARY KEY,
	|	Division TEXT,
	|	Week INTEGER,
	|	DropNumber INTEGER,
	|	Team1Name TEXT,
	|	Team2Name TEXT,
	|	Map TEXT,
	|	ViewMode TEXT,
	|	TimeOfDay TEXT,
	|	GameMode TEXT,
	|	Region TEXT,
	|	MatchTimeMinutes TEXT,
	|	UseStockLoadout BOOLEAN,
	|	NoMechQuirks BOOLEAN,
	|	NoMechEfficiencies BOOLEAN,
	|	WinningTeam TEXT,
	|	Team1Score INTEGER,
	|	Team2Score INTEGER,
	|	MatchDuration TEXT,
	|	CompleteTime TEXT
	|)";

	Return Text;
EndFunction

Function QueryTextCreateTableUserDetails()
	Text = "CREATE TABLE UserDetails (
	|	ID INTEGER PRIMARY KEY,
	|	MatchID INTEGER,
	|	Username TEXT,
	|	IsSpectator BOOLEAN,
	|	Team TEXT,
	|	Lance TEXT,
	|	MechItemID INTEGER,
	|	MechName TEXT,
	|	SkillTier INTEGER,
	|	HealthPercentage INTEGER,
	|	Kills INTEGER,
	|	KillsMostDamage INTEGER,
	|	Assists INTEGER,
	|	ComponentsDestroyed INTEGER,
	|	MatchScore INTEGER,
	|	Damage INTEGER,
	|	TeamDamage INTEGER,
	|	UnitTag TEXT
	|)";

	Return Text;
EndFunction

Function QueryTextCreateTableMechs()
	Text = "CREATE TABLE Mechs (
	|	ID INTEGER PRIMARY KEY,
	|	ItemID INTEGER,
	|	Name TEXT,
	|	Chassis TEXT,
	|	Tonnage INTEGER,
	|	Class TEXT
	|)";

	Return Text;
EndFunction

#EndRegion

#EndRegion
