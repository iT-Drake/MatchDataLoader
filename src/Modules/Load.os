////////////////////////////////////////////////////////////////////////
//
// Unit provides core functional for processing data
//
////////////////////////////////////////////////////////////////////////

#Region Public

Procedure TeamRosters(FileName, Delimiter = ",") Export
	ValueTable = ReadData.FromCSV(FileName, Delimiter);
	For Each Item In ValueTable Do
		If IsBlankString(Item.Pilot) Then
			Logger.Error("Empty pilot name found within a team: %1", Item.Team);
			Continue;
		EndIf;
		If IsBlankString(Item.Team) Then
			Logger.Error("Empty team assigned to a pilot: %1", Item.Pilot);
			Continue;
		EndIf;

		PilotData = FindPilot(Item.Pilot);
		If PilotData = Undefined Then
			AddPilot(Item.Pilot, Item.Team);
			Continue;
		EndIf;

		If PilotData.Team <> Item.Team Then
			Logger.Error("Pilot %1 already assigned to a team %2", Item.Pilot, PilotData.Team);
		EndIf;
	EndDo;
EndProcedure

Procedure MechData(FileName, Delimiter = ",") Export
	MechsTable = ReadData.FromCSV(FileName, Delimiter);
	MechList = GetMechInformation();
	If NOT ValueIsFilled(MechList) Then
		Logger.Error("Could not receive data through API.");
		Return;
	EndIf;
	
	For Each Item In MechList Do
		ItemID = Number(Item.Key);
		Line = MechsTable.Find(Item.Key, "ItemID");
		If Line = Undefined Then
			Logger.Error("%1: %2 - was not found in mech data file.", Item.Key, Item.Value);
			Continue;
		EndIf;

		MechData = FindMech(ItemID);
		If MechData = Undefined Then
			AddMech(ItemID, Line.Name, Line.Chassis, Number(Line.Tonnage), Line.Class);
			Continue;
		EndIf;

		If MechDataDiffers(MechData, Line) Then
			UpdateMech(ItemID, Line.Name, Line.Chassis, Number(Line.Tonnage), Line.Class);
		EndIf;
	EndDo;
EndProcedure

Procedure MatchData(ApiKey, FileName, Delimiter = ",") Export
	If IsBlankString(ApiKey) Then
		Raise "ApiKey is empty.
			|Visit https://mwomercs.com/profile/api to get your personal ApiKey.";
	EndIf;

	Rosters = Rosters();
	Rosters.Indexes.Add("Pilot");

	Matches = ReadData.FromCSV(FileName, Delimiter);
	For Each Match In Matches Do
		Drops = ParseDropIDs(Match.DropIDs);
		DropNumber = 0;
		DropsProcessed = 0;
		ErrorsFound = 0;
		For Each DropID In Drops Do
			DropNumber = DropNumber + 1;
			If DropExist(DropID) Then
				Continue;
			EndIf;

			Data = GetMatchData(DropID, ApiKey);
			If ErrorInMatchData(DropID, Data) Then
				ErrorsFound = ErrorsFound + 1;
				Continue;
			EndIf;

			Teams = GetTeamsData(Rosters, Data);
			If Teams = Undefined Then
				ErrorsFound = ErrorsFound + 1;
				Continue;
			EndIf;

			AddMatchDetails(Match, DropID, DropNumber, Teams, Data);
			AddUserDetails(DropID, Data);

			DropsProcessed = DropsProcessed + 1;

			Sleep(1000);
		EndDo;

		Logger.Information("[Div %1, Round %2]: `%3` vs `%4`, drops loaded: %5, errors found: %6",
			Match.Division, Match.Round, Match.Team1, Match.Team2, DropsProcessed, ErrorsFound);
	EndDo;
EndProcedure

#EndRegion

#Region Private

#Region TeamRosters

Function FindPilot(Pilot)
	Result = Undefined;
	Text = QueryText.FindPilot();
	Parameters = New Structure("Pilot", Pilot);
	ValueTable = Database.ExecuteQuery(Text, Parameters);
	
	If ValueTable.Count() = 0 Then
		Return Result;
	EndIf;
	
	Result = New Structure;
	Result.Insert("Pilot", ValueTable[0].Pilot);
	Result.Insert("Team", ValueTable[0].Team);
	
	Return Result;
EndFunction

Procedure AddPilot(Pilot, Team)
	Text = QueryText.InsertIntoTeamRosters();
	Parameters = New Structure("Pilot, Team", Pilot, Team);
	
	Database.ExecuteCommand(Text, Parameters);
EndProcedure

Function Rosters()
	Return Database.ExecuteQuery(QueryText.TeamRosters());
EndFunction

#EndRegion

#Region MechInformation

Function GetMechInformation()
	URL = "https://static.mwomercs.com/api/mechs/list/dict.json";
	Result = HTTPConnector.Get(URL);
	Return Result.Get("Mechs");
EndFunction

Function FindMech(ItemID)
	Result = Undefined;
	Text = QueryText.FindMech();
	Parameters = New Structure("ItemID", ItemID);
	ValueTable = Database.ExecuteQuery(Text, Parameters);
	
	If ValueTable.Count() = 0 Then
		Return Result;
	EndIf;

	Line = ValueTable[0];
	Result = New Structure;
	Result.Insert("Name", Line.Name);
	Result.Insert("Chassis", Line.Chassis);
	Result.Insert("Tonnage", String(Line.Tonnage));
	Result.Insert("Class", Line.Class);
	
	Return Result;
EndFunction

Procedure AddMech(ItemID, Name, Chassis, Tonnage, Class)
	Text = QueryText.InsertIntoMechs();
	Parameters = New Structure("ItemID, Name, Chassis, Tonnage, Class",
		ItemID, Name, Chassis, Tonnage, Class);
	
	Database.ExecuteCommand(Text, Parameters);
EndProcedure

Function MechDataDiffers(Mech1, Mech2)
	Return Mech1.Name <> Mech2.Name OR Mech1.Chassis <> Mech2.Chassis
		OR Mech1.Tonnage <> Mech2.Tonnage OR Mech1.Class <> Mech2.Class;
EndFunction

Procedure UpdateMech(ItemID, Name, Chassis, Tonnage, Class)
	Text = QueryText.UpdateMech();
	Parameters = New Structure("ItemID, Name, Chassis, Tonnage, Class",
		ItemID, Name, Chassis, Tonnage, Class);
	
	Database.ExecuteCommand(Text, Parameters);
EndProcedure

#EndRegion

#Region MatchData

Function GetMatchData(MatchID, ApiKey)
	URL = StrTemplate("https://mwomercs.com/api/v1/matches/%1?api_token=%2", MatchID, ApiKey);
	Return HTTPConnector.Get(URL);
EndFunction

Function ParseDropIDs(DropIDs, Delimiter = " ")
	Return StrSplit(DropIDs, Delimiter, False);
EndFunction

Function DropExist(DropID)
	Return Database.MatchExist(Number(DropID));
EndFunction

Function ErrorInMatchData(DropID, Data)
	Message = Data.Get("message");
	Status = Data.Get("status");

	If Status <> Undefined AND Message <> Undefined Then
		Logger.Error("Error loading match: %1
		|	%2: %3", DropID, Status, Message);
		Return True;
	Endif;

	Return False;
EndFunction

Function GetTeamsData(Rosters, Data)
	Result = Undefined;

	Teams = New ValueTable;
	Teams.Columns.Add("TeamName");
	Teams.Columns.Add("TeamNumber");
	Teams.Columns.Add("Pilot");
	Teams.Columns.Add("Count");

	UserDetails = Data.Get("UserDetails");
	ErrorsFound = False;
	For Each Item In UserDetails Do
		Spectator = Item.Get("IsSpectator");
		If Spectator = Undefined OR Spectator = True Then
			Continue;
		EndIf;

		Pilot = Item.Get("Username");
		PilotData = Rosters.Find(Upper(Pilot), "Pilot");
		If PilotData = Undefined Then
			Logger.Error("Pilot %1 not found in a roster.", Pilot);
			ErrorsFound = True;
			Continue;
		EndIf;

		Line = Teams.Add();
		Line.TeamName = PilotData.Team;
		Line.TeamNumber = Item.Get("Team");
		Line.Pilot = Pilot;
		Line.Count = 1;
	EndDo;

	If ErrorsFound Then
		Return Result;
	EndIf;

	Teams.GroupBy("TeamName, TeamNumber", "Count");
	Teams.Sort("Count, TeamNumber");
	If Teams.Count() <> 2 Then
		MessageText = New Array;
		MessageText.Add("More than two teams are found for the listed pilots:");
		For Each Line In Teams Do
			MessageText.Add(StrTemplate("%1. %2 - %3 pilots", Line.TeamNumber, Line.TeamName, Line.Count));
		EndDo;
		Logger.Error(StrConcat(MessageText, Chars.LF));

		Return Result;
	EndIf;

	Result = New Structure;
	Result.Insert("Team1", Teams[0].TeamName);
	Result.Insert("Team2", Teams[1].TeamName);

	Return Result;
EndFunction

Procedure AddMatchDetails(Match, DropID, DropNumber, Teams, Data)
	Parameters = New Structure;
	Parameters.Insert("MatchID", Number(DropID));
	Parameters.Insert("Division", Match.Division);
	Parameters.Insert("Round", Match.Round);
	Parameters.Insert("DropNumber", DropNumber);
	Parameters.Insert("Team1Name", Teams.Team1);
	Parameters.Insert("Team2Name", Teams.Team2);

	MatchDetails = Data.Get("MatchDetails");
	Parameters.Insert("Map", MatchDetails.Get("Map"));
	Parameters.Insert("ViewMode", MatchDetails.Get("ViewMode"));
	Parameters.Insert("TimeOfDay", MatchDetails.Get("TimeOfDay"));
	Parameters.Insert("GameMode", MatchDetails.Get("GameMode"));
	Parameters.Insert("Region", MatchDetails.Get("Region"));
	Parameters.Insert("MatchTimeMinutes", MatchDetails.Get("MatchTimeMinutes"));
	Parameters.Insert("UseStockLoadout", MatchDetails.Get("UseStockLoadout"));
	Parameters.Insert("NoMechQuirks", MatchDetails.Get("NoMechQuirks"));
	Parameters.Insert("NoMechEfficiencies", MatchDetails.Get("NoMechEfficiencies"));
	Parameters.Insert("WinningTeam", MatchDetails.Get("WinningTeam"));
	Parameters.Insert("Team1Score", MatchDetails.Get("Team1Score"));
	Parameters.Insert("Team2Score", MatchDetails.Get("Team2Score"));
	Parameters.Insert("MatchDuration", MatchDetails.Get("MatchDuration"));
	Parameters.Insert("CompleteTime", MatchDetails.Get("CompleteTime"));

	Text = QueryText.InsertIntoMatchDetails();
	Database.ExecuteCommand(Text, Parameters);
EndProcedure

Procedure AddUserDetails(DropID, Data)
	Parameters = New Structure;
	Parameters.Insert("MatchID", Number(DropID));

	UserDetails = Data.Get("UserDetails");
	Text = QueryText.InsertIntoUserDetails();
	For Each Item In UserDetails Do
		Parameters.Insert("Username", Item.Get("Username"));
		Parameters.Insert("IsSpectator", Item.Get("IsSpectator"));
		Parameters.Insert("Team", Item.Get("Team"));
		Parameters.Insert("Lance", Item.Get("Lance"));
		Parameters.Insert("MechItemID", Item.Get("MechItemID"));
		Parameters.Insert("MechName", Item.Get("MechName"));
		Parameters.Insert("SkillTier", Item.Get("SkillTier"));
		Parameters.Insert("HealthPercentage", Item.Get("HealthPercentage"));
		Parameters.Insert("Kills", Item.Get("Kills"));
		Parameters.Insert("KillsMostDamage", Item.Get("KillsMostDamage"));
		Parameters.Insert("Assists", Item.Get("Assists"));
		Parameters.Insert("ComponentsDestroyed", Item.Get("ComponentsDestroyed"));
		Parameters.Insert("MatchScore", Item.Get("MatchScore"));
		Parameters.Insert("Damage", Item.Get("Damage"));
		Parameters.Insert("TeamDamage", Item.Get("TeamDamage"));
		Parameters.Insert("UnitTag", Item.Get("UnitTag"));

		Database.ExecuteCommand(Text, Parameters);
	EndDo;
EndProcedure

#EndRegion

#EndRegion