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

Procedure PullData()
	
EndProcedure

Procedure GenerateReports()
	
EndProcedure

Procedure Test()
	ReadData.FromCSV("data\TeamRosters.csv");
EndProcedure

Procedure Finalize()
	Logger.Information("All operations completed");
	Database.Disconnect();
EndProcedure

////////////////////////////////////////////////////////////////////////
//
// Script execution divided in a few steps:
//	- Initialization - set up logging tool and establish connection to
//		the database (database file name could be customized);
//	- Data pulling - read information from about match ID's and download
//		data through MWO API;
//	- Report generation - run predefined or custom SQL-queries to
//		generate report files;
//	- Finalization - close connection to the database to save changes.
//
////////////////////////////////////////////////////////////////////////

Initialize();

PullData();

GenerateReports();

Test();

Finalize();
