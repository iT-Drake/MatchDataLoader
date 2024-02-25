////////////////////////////////////////////////////////////////////////
//
// Main executable module
//
////////////////////////////////////////////////////////////////////////

#Use "."

Procedure Initialize()
	Logger.Initialize();
	Logger.SetLogLevel(Logger.Level.Information);

	Database.Connect("data\MatchResults.db");
EndProcedure

Procedure LoadTeamRosters()
	Load.TeamRosters("data\TeamRosters.csv");
EndProcedure

Procedure LoadMechData()
	Load.MechData("data\MechData.csv");
EndProcedure

Procedure LoadMatchData()
	ApiKey = "";
	Load.MatchData(ApiKey, "data\Matches.csv");
EndProcedure

Procedure GenerateReports()
	Queries = New Structure;
	Queries.Insert("PilotWithMostDamageDealt", QueryText.PilotWithMostDamageDealt());
	Queries.Insert("TeamWithMostDamageDealt", QueryText.TeamWithMostDamageDealt());

	Result = Database.ExecuteBatchQuery(Queries);
	For Each Item In Result Do
		FileName = StrTemplate("reports\%1.csv", Item.Key);
		WriteData.ToCSV(FileName, Item.Value);
	EndDo;
EndProcedure

Procedure Finalize()
	Database.Disconnect();
	Logger.Information("All operations completed");
EndProcedure

////////////////////////////////////////////////////////////////////////
//
// Script execution divided in a few steps:
//	- Initialization - sets up logging tool and establishes connection
//		to the database (creates it if not exist);
//	- Initial filling - loads in information about team rosters and
//		mechs (need to run it only once unless there are updates);
//	- Data pulling - read match ID's and download data through MWO API;
//	- Report generation - run predefined or custom SQL-queries to
//		generate report files;
//	- Finalization - close connection to the database to save changes.
//
//	Any step between Initialization and Finalization may be skipped,
//	just comment the method call.
//	Folder structure and file names could be customized.
//
////////////////////////////////////////////////////////////////////////

Initialize();

////////////////////////////////////////////////////////////////////////
// Step 1
////////////////////////////////////////////////////////////////////////

LoadTeamRosters();
LoadMechData();

////////////////////////////////////////////////////////////////////////
// Step 2
////////////////////////////////////////////////////////////////////////

LoadMatchData();

////////////////////////////////////////////////////////////////////////
// Step 3
////////////////////////////////////////////////////////////////////////

GenerateReports();

Finalize();
