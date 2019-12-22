/* shortthrees.sas

Author:		Arthur Sweetman
Directory:	M:\STA 402\final-project
Purpose:	Investigate the proportion of shots that were closer than 
			22 feet away and were counted as 3-pointers
*/

libname proj "M:\STA 402\final-project";

data shortthrees;
	set proj.shotlogs_splitted;
	if pts_type = 3 & shot_dist < 22 then
		short3 = 1;
	else short3 = 0;
run;

title 'Proportion of "Short" Threes Compared to all Threes Attempted';
ods rtf bodytitle file="M:\STA 402\final-project\shortthrees.rtf";
proc freq data=shortthrees;
	table short3*pts_type;
run;
ods rtf close;
title;
