# NBA-data-analysis-2014-2015

## Prerequisites
1. Must have SAS installed

## Getting Started
1. Clone repository
2. Open `graphic.sas` in SAS
3. Run file as is
4. View results in SAS

## Modifications
If you would like to customize this output for a different:
* Player
* Team
* Date

1. Open `graphic.sas` in SAS
2. Scroll to bottom
3. Modify the following code block in `graphic.sas` according to the specifications
```
/**************
DUE TO RESTRICTIONS IN THE DATA SET,
NAMES ARE CUT OFF AFTER 13 CHARACTERS,
ONLY TYPE A PLAYER'S NAME UP TO THEIR 13TH CHARACTER,
ALL LOWER CASE.
teamname MUST be a proper 3-letter uppercase abbreviation for an NBA team
gamedate MUST be between 10/28/14 - 03/04/15 and in the format mm/dd/yy
*/

%plotshots20142015nba(
playername=stephen curry,
/**********1234567890123*/
teamname=GSW,
gamedate=12/25/14
);
```
4. Save your changes
5. Run block of code
6. View results in SAS
