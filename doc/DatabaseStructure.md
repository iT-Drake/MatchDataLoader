# Database structure

### Table MatchDetails

| Column | Type |
|--------|------|
| MatchID | INTEGER PRIMARY KEY |
| Division | TEXT |
| Round | INTEGER |
| DropNumber | INTEGER |
| Team1Name | TEXT |
| Team2Name | TEXT |
| Map | TEXT |
| ViewMode | TEXT |
| TimeOfDay | TEXT |
| GameMode | TEXT |
| Region | TEXT |
| MatchTimeMinutes | TEXT |
| UseStockLoadout | BOOLEAN |
| NoMechQuirks | BOOLEAN |
| NoMechEfficiencies | BOOLEAN |
| WinningTeam | TEXT |
| Team1Score | INTEGER |
| Team2Score | INTEGER |
| MatchDuration | TEXT |
| CompleteTime | TEXT |

### Table UserDetails

| Column | Type |
|--------|------|
| ID | INTEGER PRIMARY KEY |
| MatchID | INTEGER |
| Username | TEXT |
| IsSpectator | BOOLEAN |
| Team | TEXT |
| Lance | TEXT |
| MechItemID | INTEGER |
| MechName | TEXT |
| SkillTier | INTEGER |
| HealthPercentage | INTEGER |
| Kills | INTEGER |
| KillsMostDamage | INTEGER |
| Assists | INTEGER |
| ComponentsDestroyed | INTEGER |
| MatchScore | INTEGER |
| Damage | INTEGER |
| TeamDamage | INTEGER |
| UnitTag | TEXT |

### Table Mechs

| Column | Type |
|--------|------|
| ItemID | INTEGER NOT NULL PRIMARY KEY |
| Name | TEXT |
| Chassis | TEXT |
| Tonnage | INTEGER |
| Class | TEXT |

### Table TeamRosters

| Column | Type |
|--------|------|
| Pilot | TEXT NOT NULL COLLATE NOCASE PRIMARY KEY |
| Team | TEXT |
