#Use "."

Procedure Initialize()
	Logger.Initialize("oscript.app.matchdataloader");
	Logger.SetLogLevel(Logger.Level.Information);

	Database.Connect("data\MatchResults.db");
EndProcedure

Initialize();
