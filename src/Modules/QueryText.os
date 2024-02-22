////////////////////////////////////////////////////////////////////////
//
// Unit provides access to common query templates
//
////////////////////////////////////////////////////////////////////////

#Region CreateTable

Function CreateTableMatchDetails() Export
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

Function CreateTableUserDetails() Export
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

Function CreateTableMechs() Export
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

Function CreateTableTeamRosters() Export
	Text = "CREATE TABLE Mechs (
	|	ID INTEGER PRIMARY KEY,
	|	Team TEXT,
	|	Pilot TEXT COLLATE NOCASE
	|)";

	Return Text;
EndFunction

#EndRegion

#Region InsertInto

Function InsertIntoMatchDetails() Export
	Text = "INSERT INTO MatchDetails (MatchID, Division, Week, DropNumber, Team1Name, Team2Name, Map, ViewMode, TimeOfDay, GameMode, Region,
	|	MatchTimeMinutes, UseStockLoadout, NoMechQuirks, NoMechEfficiencies, WinningTeam, Team1Score, Team2Score, MatchDuration, CompleteTime)
	|VALUES (@MatchID, @Division, @Week, @DropNumber, @Team1Name, @Team2Name, @Map, @ViewMode, @TimeOfDay, @GameMode, @Region, @MatchTimeMinutes,
	|	@UseStockLoadout, @NoMechQuirks, @NoMechEfficiencies, @WinningTeam, @Team1Score, @Team2Score, @MatchDuration, @CompleteTime)
	|";

	Return Text;
EndFunction

Function InsertIntoUserDetails() Export
	Text = "INSERT INTO UserDetails (MatchID, Username, IsSpectator, Team, Lance, MechItemID, MechName, SkillTier,
	|	HealthPercentage, Kills, KillsMostDamage, Assists, ComponentsDestroyed, MatchScore, Damage, TeamDamage, UnitTag)
	|VALUES (@MatchID, @Username, @IsSpectator, @Team, @Lance, @MechItemID, @MechName, @SkillTier, @HealthPercentage,
	|	@Kills, @KillsMostDamage, @Assists, @ComponentsDestroyed, @MatchScore, @Damage, @TeamDamage, @UnitTag)
	|";

	Return Text;
EndFunction

Function InsertIntoMechs() Export
	Text = "INSERT INTO Mechs (ItemID, Name, Chassis, Tonnage, Class)
	|	VALUES (@ItemID, @Name, @Chassis, @Tonnage, @Class)
	|";

	Return Text;
EndFunction

Function InsertIntoTeamRosters() Export
	Text = "INSERT INTO TeamRosters (Team, Pilot)
	|	VALUES (@Team, @Pilot)
	|";

	Return Text;
EndFunction

#EndRegion

#Region Select

Function FindMatchID() Export
	Return "SELECT MatchID FROM MatchDetails WHERE MatchID = @MatchID";
EndFunction

#EndRegion