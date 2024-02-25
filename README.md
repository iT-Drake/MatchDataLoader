# MatchDataLoader

This tool is designed to ease tracking of private lobby matches in `MechWarrior Online`.
Local SQLite database is designed to store information about team rosters, mechs, matches and their participants.
MWO API is used for data pulling which require an ApiKey that you can get [here](https://mwomercs.com/profile/api).

A set of SQL-queries is provided with the tool that will help you dig through data and generate reports.

Supported report formats are:
- CSV - text file with comma-separated values;
- Space-aligned text - could be used in a code block in Discord or with any monospace font.

# Requirements
### OneScript execution environment

OneScript is a .NET-based script-execution environment made by Andrei Ovsiankin. Download link: https://github.com/EvilBeaver/OneScript

### OneScript libraries

This project is dependent on two libraries:
- SQL: https://github.com/oscript-library/sql
- 1Connector: https://github.com/oscript-library/1connector

OneScript provides its own package-manager - OPM. You can use these commands to download dependencies:
```shell
opm install sql
opm install 1connector
```

# Database structure

Default database file that is created in the process of script execution contains following tables:
- MatchDetails - contains generak information about the match like map, game mode, winning team, match duration;
- UserDetails - contains information about players and their results like tag, name, damage dealt, mech that've been used;
- Mechs - data format of API response provides mech ID that needs to be converted into human-readable form, table contains detailed information about the mech;
- TeamRosters - helps to identify which teams were playing in the match.

Detailed information about table fields could be found [here](doc/DatabaseStructure.md).

# Use examples

Install OneScript, download dependencies. Download or clone repository.

Fill in team rosters (by default file `data/TeamRosters.csv` will be used).
```
Team,Pilot
Clan Ghost Bear,Nicholas Kerensky
```

Update mech data if any new mechs were released (default file: `data/MechData.csv`). If mech will not be found in a file, script will throw an error.
```
ItemID,Name,Chassis,Tonnage,Class
3681,BL-X-KNT-2,BL-KNT,75,HEAVY
```

Fill in matches (default file: `data/Matches.csv`). Script isn't using `Team1` and `Team2` fields, but their are useful for a manual check of the file. Drop ID's, if there are multiple in one match, should be separated with a space like this:
```
Round,Division,Team1,Team2,DropIDs
1,A,Clan Ghost Bear,Clan Jade Falcon,487519148581506 487184141131062 488120444005522 487811206358963 488382437011588
```

To run a script from a command line you need to change directory to your downloaded repository and run:
```shell
oscript src/main.os
```

For debug and develop purposes you can get `OneScript Debug (BSL)` extension for VisualStudio Code make a JSON-file with default settings from "Run and Debug" tab and then execute the script from within IDE.
