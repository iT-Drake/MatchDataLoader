////////////////////////////////////////////////////////////////////////
//
// Unit provides access to common query templates
//
////////////////////////////////////////////////////////////////////////

#Region CreateTable

Function CreateTableMatchDetails() Export
	Text = "CREATE TABLE IF NOT EXISTS MatchDetails (
	|	MatchID INTEGER PRIMARY KEY,
	|	Division TEXT,
	|	Round INTEGER,
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
	Text = "CREATE TABLE IF NOT EXISTS UserDetails (
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
	Text = "CREATE TABLE IF NOT EXISTS Mechs (
	|	ItemID INTEGER NOT NULL PRIMARY KEY,
	|	Name TEXT,
	|	Chassis TEXT,
	|	Tonnage INTEGER,
	|	Class TEXT
	|)";

	Return Text;
EndFunction

Function CreateTableTeamRosters() Export
	Text = "CREATE TABLE IF NOT EXISTS TeamRosters (
	|	Pilot TEXT NOT NULL COLLATE NOCASE,
	|	Team TEXT,
	|	PRIMARY KEY(Pilot)
	|)";

	Return Text;
EndFunction

#EndRegion

#Region InsertInto

Function InsertIntoMatchDetails() Export
	Text = "INSERT INTO MatchDetails (MatchID, Division, Round, DropNumber, Team1Name, Team2Name, Map, ViewMode, TimeOfDay, GameMode, Region,
	|	MatchTimeMinutes, UseStockLoadout, NoMechQuirks, NoMechEfficiencies, WinningTeam, Team1Score, Team2Score, MatchDuration, CompleteTime)
	|VALUES (@MatchID, @Division, @Round, @DropNumber, @Team1Name, @Team2Name, @Map, @ViewMode, @TimeOfDay, @GameMode, @Region, @MatchTimeMinutes,
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
	Text = "INSERT INTO TeamRosters (Pilot, Team)
	|	VALUES (@Pilot, @Team)
	|";

	Return Text;
EndFunction

#EndRegion

#Region Select

Function FindMatchID() Export
	Return "SELECT MatchID FROM MatchDetails WHERE MatchID = @MatchID";
EndFunction

Function FindPilot() Export
	Return "SELECT Pilot, Team FROM TeamRosters WHERE Pilot = @Pilot";
EndFunction

Function FindMech() Export
	Return "SELECT Name, Chassis, Tonnage, Class FROM Mechs WHERE ItemID = @ItemID";
EndFunction

Function TeamRosters() Export
	Return "SELECT UPPER(Pilot), Team FROM TeamRosters";
EndFunction

#EndRegion

#Region Update

Function UpdateMech() Export
	Return "UPDATE Mechs
	|	SET Name = @Name, Chassis = @Chassis, Tonnage = @Tonnage, Class = @Class
	|	WHERE ItemID = @ItemID";
EndFunction

#EndRegion

#Region Reports

Function UniquePilots() Export
	Text = "
	|SELECT
	|	M.Division AS Division,
	|	TeamRoster.Team AS Team,
	|	COUNT(DISTINCT U.UserName) AS UniquePilots
	|FROM UserDetails AS U
	|	LEFT JOIN MatchDetails AS M
	|		ON M.MatchID = U.MatchID
	|	LEFT JOIN TeamRoster
	|		ON TeamRoster.Pilot = U.UserName
	|WHERE
	|	NOT U.IsSpectator
	|
	|GROUP BY
	|	M.Division,
	|	TeamRoster.Team
	|
	|ORDER BY
	|	Division, Team
	|";

	Return Text;
EndFunction

Function DataDump() Export
	Text = "
	|SELECT
	|	M.Division AS Division,
	|	M.Week AS Round,
	|	M.DropNumber AS DropNumber,
	|	M.MatchID AS MatchID,
	|	M.Map AS Map,
	|	M.MatchDuration AS MatchDuration,
	|	M.Team1Name AS Team1,
	|	M.Team2Name AS Team2,
	|	M.Team1Score AS Team1Score,
	|	M.Team2Score AS Team2Score,
	|	CASE WHEN M.WinningTeam = U.Team THEN ""WIN"" WHEN U.IsSpectator THEN """" ELSE ""LOSS"" END AS Result,
	|	CASE WHEN U.IsSpectator THEN ""YES"" ELSE ""NO"" END AS Spectator,
	|	CASE WHEN U.Team = 1 THEN M.Team1Name WHEN U.Team = 2 THEN M.Team2Name ELSE ""SPECTATORS"" END AS Team,
	|	U.UnitTag AS Tag,
	|	U.Lance AS Lance,
	|	U.Username AS Pilot,
	|	Mechs.Name AS Mech,
	|	Mechs.Chassis AS Chassis,
	|	Mechs.Tonnage AS Tonnage,
	|	Mechs.Class AS Class,
	|	CASE WHEN U.IsSpectator THEN """" WHEN U.HealthPercentage = 0 THEN ""DEAD"" ELSE CAST(U.HealthPercentage AS TEXT) END AS Health,
	|	U.Kills AS Kills,
	|	U.KillsMostDamage AS KillsMostDamage,
	|	U.Assists AS Assists,
	|	U.ComponentsDestroyed AS ComponentsDestroyed,
	|	U.MatchScore AS MatchScore,
	|	U.Damage AS Damage,
	|	U.TeamDamage AS TeamDamage
	|FROM UserDetails AS U
	|	LEFT JOIN MatchDetails AS M
	|		ON M.MatchID = U.MatchID
	|	LEFT JOIN Mechs
	|		ON Mechs.ItemID = U.MechItemID
	|
	|ORDER BY
	|	Division, Round, DropNumber, Team1, Spectator, Team
	|";

	Return Text;
EndFunction

Function TeamDamage() Export
	Text = "
	|SELECT
	|	TeamRosters.Team AS Team,
	|	UserDetails.Username,
	|	SUM(UserDetails.TeamDamage) AS Damage,
	|	SUM(CASE
	|		WHEN TeamDamage > 0
	|		THEN 1
	|		ELSE 0
	|	END) AS Drops
	|FROM
	|	UserDetails
	|	INNER JOIN TeamRosters
	|		ON TeamRosters.Pilot = UserDetails.Username
	|
	|GROUP BY
	|	TeamRosters.Team,
	|	UserDetails.Username
	|
	|ORDER BY
	|	Damage DESC,
	|	Drops DESC
	|
	|LIMIT 10
	|";

	Return Text;
EndFunction

Function PilotWithMostKills() Export
	Text = "
	|SELECT
	|	CASE
	|		WHEN U.Team = 1
	|		THEN M.Team1Name
	|		ELSE M.Team2Name
	|	END AS Team,
	|	U.Username AS Pilot,
	|	SUM(U.Kills) AS Kills,
	|	SUM(U.KillsMostDamage) AS KMDDs
	|FROM UserDetails AS U
	|	LEFT JOIN MatchDetails AS M
	|		ON M.MatchID = U.MatchID
	|
	|GROUP BY
	|	CASE
	|		WHEN U.Team = 1
	|		THEN M.Team1Name
	|		ELSE M.Team2Name
	|	END,
	|	U.Username
	|
	|ORDER BY
	|	Kills DESC,
	|	KMDDs DESC
	|
	|LIMIT 10
	|";
	
	Return Text;
EndFunction

Function PilotWithMostKillsPerMatch() Export
	Text = "
	|SELECT
	|	M.Round AS Round,
	|	CASE
	|		WHEN U.Team = 1
	|		THEN M.Team1Name
	|		ELSE M.Team2Name
	|	END AS Team,
	|	U.Username AS Pilot,
	|	SUM(U.Kills) AS Kills,
	|	SUM(U.KillsMostDamage) AS KMDDs
	|FROM UserDetails AS U
	|	LEFT JOIN MatchDetails AS M
	|		ON M.MatchID = U.MatchID
	|
	|GROUP BY
	|	M.Round,
	|	CASE
	|		WHEN U.Team = 1
	|		THEN M.Team1Name
	|		ELSE M.Team2Name
	|	END,
	|	U.Username
	|
	|ORDER BY
	|	Kills DESC,
	|	KMDDs DESC
	|
	|LIMIT 10
	|";
	
	Return Text;
EndFunction

Function PilotWithMostKillsPerDrop() Export
	Text = "
	|SELECT
	|	M.Round AS Round,
	|	M.DropNumber AS DropNumber,
	|	CASE
	|		WHEN U.Team = 1
	|		THEN M.Team1Name
	|		ELSE M.Team2Name
	|	END AS Team,
	|	U.Username AS Pilot,
	|	SUM(U.Kills) AS Kills,
	|	SUM(U.KillsMostDamage) AS KMDDs
	|FROM UserDetails AS U
	|	LEFT JOIN MatchDetails AS M
	|		ON M.MatchID = U.MatchID
	|
	|GROUP BY
	|	M.Round,
	|	M.DropNumber,
	|	CASE
	|		WHEN U.Team = 1
	|		THEN M.Team1Name
	|		ELSE M.Team2Name
	|	END,
	|	U.Username
	|
	|ORDER BY
	|	Kills DESC,
	|	KMDDs DESC
	|
	|LIMIT 10
	|";
	
	Return Text;
EndFunction

Function TeamWithMostKills() Export
	Text = "
	|SELECT
	|	TeamRosters.Team AS Team,
	|	SUM(U.Kills) AS Kills
	|FROM
	|	UserDetails
	|	INNER JOIN TeamRosters
	|		ON TeamRosters.Pilot = UserDetails.Username
	|
	|GROUP BY
	|	TeamRosters.Team
	|
	|ORDER BY
	|	Kills DESC
	|
	|LIMIT 10
	|";
	
	Return Text;
EndFunction

Function PilotWithMostDamageDealt() Export
	Text = "
	|SELECT
	|	CASE
	|		WHEN U.Team = 1
	|		THEN M.Team1Name
	|		ELSE M.Team2Name
	|	END AS Team,
	|	U.Username AS Pilot,
	|	SUM(U.Damage) AS Damage
	|FROM UserDetails AS U
	|	LEFT JOIN MatchDetails AS M
	|		ON M.MatchID = U.MatchID
	|
	|GROUP BY
	|	CASE
	|		WHEN U.Team = 1
	|		THEN M.Team1Name
	|		ELSE M.Team2Name
	|	END,
	|	U.Username
	|
	|ORDER BY
	|	Damage DESC
	|
	|LIMIT 10
	|";
	
	Return Text;
EndFunction

Function PilotWithMostDamageDealtPerMatch() Export
	Text = "
	|SELECT
	|	M.Round AS Round,
	|	CASE
	|		WHEN U.Team = 1
	|		THEN M.Team1Name
	|		ELSE M.Team2Name
	|	END AS Team,
	|	U.Username AS Pilot,
	|	SUM(U.Damage) AS Damage
	|FROM UserDetails AS U
	|	LEFT JOIN MatchDetails AS M
	|		ON M.MatchID = U.MatchID
	|
	|GROUP BY
	|	M.Round,
	|	CASE
	|		WHEN U.Team = 1
	|		THEN M.Team1Name
	|		ELSE M.Team2Name
	|	END,
	|	U.Username
	|
	|ORDER BY
	|	Damage DESC
	|
	|LIMIT 10
	|";
	
	Return Text;
EndFunction

Function PilotWithMostDamageDealtPerDrop() Export
	Text = "
	|SELECT
	|	M.Round AS Round,
	|	M.DropNumber AS DropNumber,
	|	CASE
	|		WHEN U.Team = 1
	|		THEN M.Team1Name
	|		ELSE M.Team2Name
	|	END AS Team,
	|	U.Username AS Pilot,
	|	SUM(U.Damage) AS Damage
	|FROM UserDetails AS U
	|	LEFT JOIN MatchDetails AS M
	|		ON M.MatchID = U.MatchID
	|
	|GROUP BY
	|	M.Round,
	|	M.DropNumber,
	|	CASE
	|		WHEN U.Team = 1
	|		THEN M.Team1Name
	|		ELSE M.Team2Name
	|	END,
	|	U.Username
	|
	|ORDER BY
	|	Damage DESC
	|
	|LIMIT 10
	|";
	
	Return Text;
EndFunction

Function TeamWithMostDamageDealt() Export
	Text = "
	|SELECT
	|	CASE
	|		WHEN U.Team = 1
	|		THEN M.Team1Name
	|		ELSE M.Team2Name
	|	END AS Team,
	|	SUM(U.Damage) AS Damage
	|FROM UserDetails AS U
	|	LEFT JOIN MatchDetails AS M
	|		ON M.MatchID = U.MatchID
	|
	|GROUP BY
	|	CASE
	|		WHEN U.Team = 1
	|		THEN M.Team1Name
	|		ELSE M.Team2Name
	|	END
	|
	|ORDER BY
	|	Damage DESC
	|
	|LIMIT 10
	|";
	
	Return Text;
EndFunction

Function TeamWithMostDamageDealtPerMatch() Export
	Text = "CREATE TEMPORARY TABLE DamagePerMatch AS
	|SELECT
	|	M.Week AS Round,
	|	CASE
	|		WHEN U.Team = 1
	|		THEN M.Team1Name
	|		ELSE M.Team2Name
	|	END AS Team,
	|	SUM(U.Damage) AS Damage
	|FROM UserDetails AS U
	|	LEFT JOIN MatchDetails AS M
	|		ON M.MatchID = U.MatchID
	|
	|GROUP BY
	|	M.Week,
	|	CASE
	|		WHEN U.Team = 1
	|		THEN M.Team1Name
	|		ELSE M.Team2Name
	|	END
	|;
	|SELECT
	|	T.Round AS Round,
	|	T.Team AS Team,
	|	T.Damage AS Damage
	|FROM
	|	DamagePerMatch AS T
	|	INNER JOIN (
	|		SELECT
	|			Team AS Team,
	|			MAX(Damage) AS Damage
	|		FROM
	|			DamagePerMatch
	|
	|		GROUP BY
	|			Team
	|	) AS MaxDamage
	|		ON MaxDamage.Team = T.Team
	|			AND MaxDamage.Damage = T.Damage
	|
	|ORDER BY
	|	Damage DESC
	|
	|LIMIT 10
	|";
	
	Return Text;
EndFunction

Function TeamWithMostDamageDealtPerDrop() Export
	Text = "CREATE TEMPORARY TABLE DamagePerDrop AS
	|SELECT
	|	M.Week AS Round,
	|	M.DropNumber AS DropNumber,
	|	CASE
	|		WHEN U.Team = 1
	|		THEN M.Team1Name
	|		ELSE M.Team2Name
	|	END AS Team,
	|	SUM(U.Damage) AS Damage
	|FROM UserDetails AS U
	|	LEFT JOIN MatchDetails AS M
	|		ON M.MatchID = U.MatchID
	|
	|GROUP BY
	|	M.Week,
	|	M.DropNumber,
	|	CASE
	|		WHEN U.Team = 1
	|		THEN M.Team1Name
	|		ELSE M.Team2Name
	|	END
	|;
	|SELECT
	|	T.Round AS Round,
	|	T.DropNumber AS DropNumber,
	|	T.Team AS Team,
	|	T.Damage AS Damage
	|FROM
	|	DamagePerDrop AS T
	|	INNER JOIN (
	|		SELECT
	|			Team AS Team,
	|			MAX(Damage) AS Damage
	|		FROM
	|			DamagePerDrop
	|
	|		GROUP BY
	|			Team
	|	) AS MaxDamage
	|		ON MaxDamage.Team = T.Team
	|			AND MaxDamage.Damage = T.Damage
	|
	|ORDER BY
	|	Damage DESC
	|
	|LIMIT 10
	|";
	
	Return Text;
EndFunction

#EndRegion

#Region DeleteFrom

Function DeleteFromMatchDetails() Export
	Return "DELETE FROM MatchDetails";
EndFunction

Function DeleteFromUserDetails() Export
	Return "DELETE FROM UserDetails";
EndFunction

Function DeleteFromMechs() Export
	Return "DELETE FROM Mechs";
EndFunction

Function DeleteFromTeamRosters() Export
	Return "DELETE FROM TeamRosters";
EndFunction

Function DeleteMatchInformation() Export
	Return "DELETE FROM UserDetails WHERE MatchID = @MatchID;
		|DELETE FROM MatchDetails WHERE MatchID = @MatchID";
EndFunction

#EndRegion
