/* homeandaway.sas

Author:		Arthur Sweetman
Directory:	M:\STA 402\final-project
Date:		04 November 2019
Purpose:	This file imports the data set shot_logs.csv and proceeds 
			to record the date, home team, and away team based off the 
			String varible "matchup".

*/

libname proj "M:\STA 402\final-project";

proc import datafile="M:\STA 402\final-project\shot_logs.csv"
	out=proj.shotlogs
	dbms=csv
	;
run;

proc sort data=proj.shotlogs;
	by game_id1;
run;

data proj.shotlogs_splitted;

	set proj.shotlogs;
	format date mmddyy9.;
	date=input(matchup, anydtdte12.);

	array word[6] $;
	drop i;
	do i = 1 to 6;
		word[i] = scan(matchup, i);
	end;

	if word5 = "@" then 
		do;
			home=word6;
			away=word4;
		end;
	else 
		do;
			home=word4;
			away=word6;
		end;
	drop word1-word6;

	if location="H" then
		team = home;
	else
		team = away;

run;
