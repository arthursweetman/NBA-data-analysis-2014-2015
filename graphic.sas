/* graphic.sas

Author:		Arthur Sweetman
Purpose:	Create useful graphics illustrating the distribution
			of shot distances in the 2014-2015 NBA season (can be
			filtered by player name, team name, and date).
*/

%let directory = C:\Users\arthu\Documents\GitHub\NBA-data-analysis-2014-2015;

%macro plotshots20142015nba (playername=, teamname= , gamedate=);

libname proj "&directory";

proc import datafile="&directory\shot_logs.csv"
	out=proj.shotlogs
	dbms=csv
	;
run;

/* This data step is used to draw the basketball court
	(not including the curved 3-point lines) */
data courtlines;
	infile "&directory\courtanno.txt" expandtabs pad;
	retain drawspace "datavalue" linecolor "black";
	input function $9. x1 y1 x2 y2 height width anchor $10.;
run;

* This data step is only used to draw each of the curved 3-point arcs;
data threepointarcs;
	retain drawspace "datavalue" linecolor "black";

	do;
		function="polyline"; x1=3; y1=14; x2=.; y2=.;
			* starting point of lower 3-point line;
			height=.; width=.; anchor="";
		output;
	end;
	do x1 = 3 to 47 by .01;
		function = "polycont";
		y1 = sqrt(564.0625-((x1-25)**2))+4.75;
			* equation of lower 3-point line;
		x2=.; y2=.; height=.; width=.; anchor="";
		output;
	end;

	do;
		function="polyline"; x1=3; y1=80; x2=.; y2=.;
			* starting point of upper 3-point line;
			height=.; width=.; anchor="";
		output;
	end;
	do x1 = 3 to 47 by .01;
		function = "polycont";
		y1 = -sqrt(564.0625-((x1-25)**2))+89.25;
			* equation of upper 3-point line;
		x2=.; y2=.; height=.; width=.; anchor="";
		output;
	end;

run;

/* Combine the above data sets into one so the entire
	court annotation is in one data set */
data drawcourt;
	set courtlines threepointarcs;
run;

/* Set shot distances in terms of polar coordinates to use for plotting.
	This DATA step also filters the output based on the user input. */
data shotlogs_polar;
	set proj.shotlogs_splitted;

	/* In order to properly filter by date, we have to convert the input date
		into a SAS date format */
	%if &gamedate^= %then %do; %let fdate = input("&gamedate", anydtdte12.); %end;

	/* In this string of %IF/%ELSE %IF statements, we filter the dataset based on
		which inputs the user put in the macro */
	%if &playername^= & &teamname^= & &gamedate^= %then
		%do;
			where player_name="&playername" and team="&teamname" and date=&fdate;
			title "&playername's Shot Distribution on &gamedate";
		%end;
	%else %if &playername^= & &teamname^= %then
		%do;
			where player_name="&playername" and team="&teamname";
			title "&playername's Shot Distribution";
		%end;
	%else %if &playername^= & &gamedate^= %then
		%do;
			where player_name="&playername" and date=&fdate;
			title "&playername's Shot Distribution on &gamedate";
		%end;
	%else %if &teamname^= & &gamedate^= %then
		%do;
			where team="&teamname" and date=&fdate;
			title "&teamname's Shot Distribution on &gamedate";
		%end;
	%else %if &playername^= %then
		%do;
			where player_name="&playername";
			title "&playername's Shot Distribution";
		%end;
	%else %if &teamname^= %then
		%do;
			where team="&teamname";
			title "&teamname's Shot Distribution";
		%end;
	%else %if &gamedate^= %then
		%do;
			where date=&fdate;
			title "Shot Distribution of all players on &gamedate";
		%end;

	/* Make sure all shots are plotted on the basketball court
		and can be seen in the graphic */
	radius = shot_dist;
	if radius > 25 then
		theta = rand('uniform', arcos(25/radius), 3.14-arcos(25/radius));
	else
		theta = rand('uniform', 0, 3.14);

	* Make sure shots taken from the corner 3-point line are plotted appropriately;
	if radius < 23.75 & radius >= 22 & pts_type = 3 then
		do;
			indicator = rand('bernoulli', .5);
			if indicator = 1 then
				theta = rand('uniform', 0, arcos(22/radius));
			else
				theta = rand('uniform', 3.14-arcos(22/radius), 3.14);
		end;

	* Assign made and missed shots to different variables for plotting;
	if shot_result = "made" then
		do;
			madex = radius*cos(theta)+25;
			madey = radius*sin(theta)+4.75;
		end;
	else
		do;
			missedx = radius*cos(theta)+25;
			missedy = radius*sin(theta)+4.75;
		end;

	* Assign a shot as "close", "mid", or "long" range;
	if shot_dist < 12 then
		range = "Short";
	else if shot_dist < 22 then
		range = "Mid";
	else
		range = "Long";

	/* Assign labels to variables displayed in the output */
	label range="Distance" shot_result="Shot Result";

run;

/****************************Plot data*******************************/

/* This plot uses the annotation dataset "drawcourt" to draw the basketball
	court and then plot the shots onto the court */
proc sgplot data=shotlogs_polar sganno=drawcourt aspect=2 noborder;
	xaxis min=0 max=50 display=none;
	yaxis min=0 max=94 display=none;
	scatter x=madex y=madey /
		transparency=0 markerattrs=(color=blue size=3)
		legendlabel="Made";
	scatter x=missedx y=missedy /
		transparency=0 markerattrs=(symbol=X color=red size=3)
		legendlabel="Missed";
run;

/* This plot outputs a histogram of all shots (filtered) according
	to their distance away from the basket. This is a visual to complement
	the above plot */
proc sgplot data=shotlogs_polar;
	histogram shot_dist / binwidth=1 boundary=lower;
	density shot_dist / type=kernel;
	refline 12 / axis=x label="Mid-Range";
	refline 22 / axis=x label="Long-Range";
	xaxis label="Shot Distance" values=(0 to 50 by 2);
	yaxis label="Shot Frequency (Percent)";
run;

/* This outputs a frequncy plot that helps the user see numerical
	values and proportions which correlate to the output of the
	above plots */
proc freq data=shotlogs_polar;
	table range*shot_result;
run;

%mend plotshots20142015nba;

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
teamname=,
gamedate=
);
