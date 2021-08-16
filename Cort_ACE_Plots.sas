* set library;
libname cort "C:/Users/mcraft/Desktop/ACE and Cortisol Figures/ods output";
*export fixed and random effects to data sets;
ods output ConvergenceStatus = cort.myconvstat
		   ParameterEstimates = cort.myparamest
		   CovMatParmEst = cort.mycovmat 
		   FitStatistics = cort.myfitstats
		   Dimensions = cort.mydimensions
		   CorrMatParmEst = cort.mycorrmat;
*this script will output random effects for each person to a file called forplot;
title1 'linear-exponential continuous time model heterogenous level 1 residual variance';
title3 'unconditional model for ACE_c6';
proc nlmixed data=all_long2 gconv=0 noad qpoints=10 corr cov;  
where B1PAGE_M2>=0 and fem>=0 and ACE_c6>=0 and dailymeannumstressors>=0 and HSGEDplus>=0;
parms
f00 3.0085
f10 0.6179
f20 0.8789
f30 0.1224
tau0 -1.6874
t_u0 -1.7008
rhou1u0 0.2573
t_u1 -1.7479
rhou2u0 0.2763
rhou2u1 0.00578
t_u2 -1.5581
rhowu0 -0.04297
rhowu1 0.148
rhowu2 0.5427
t_w -1.0535;

s2e = exp(tau0 + wi);
knot = 0;
a0 = f00 + u0; a1 = f10 + u1; b1 = f20 + u2; b2 = f30;
sdu0 = sqrt(exp(t_u0));
sdu1 = sqrt(exp(t_u1));
sdu2 = sqrt(exp(t_u2));
sdw  = sqrt(exp(t_w));

if (CORTpctime <= knot) then predv = a0 + a1*CORTpctime;
if (CORTpctime > knot)  then predv =  b1 - (b1 - ((a0 + a1*knot - b1 + b1*exp(-b2*knot))/ (exp(-b2*knot))))*exp(-b2*CORTpctime) ;
predict a0 out = cort.mixedeffect_a0;
predict a1 out = cort.mixedeffect_a1;
predict b1 out = cort.mixedeffect_b1;
predict predv out = cort.myprediction;
model logcort ~ normal(predv,s2e);
random u0 u1 u2 wi ~ normal([0,0,0,0],[sdu0*sdu0,
                                       rhou1u0*sdu0*sdu1,sdu1*sdu1,
                                       rhou2u0*sdu0*sdu2,rhou2u1*sdu1*sdu2,sdu2*sdu2,
                                       rhowu0*sdu0*sdw,  rhowu1*sdu1*sdw, rhowu2*sdu2*sdw, sdw*sdw]) subject= m2id out=cort.myrandomeffects;
run;
ods output close;
* remove extra variables;
data cort.mixedeffect_a0;
	set cort.mixedeffect_a0 (keep = M2ID Pred StdErrPred DF tValue Probt Alpha Lower Upper
	rename = (Pred = Pred_a0 StdErrPred = StdErrPred_a0 DF = DF_a0 tValue = tValue_a0
			  Probt = Probt_a0 Alpha = Alpha_a0 Lower = Lower_a0 Upper = Upper_a0));
run;
data cort.mixedeffect_a1;
	set cort.mixedeffect_a1 (keep = M2ID Pred StdErrPred DF tValue Probt Alpha Lower Upper
	rename = (Pred = Pred_a1 StdErrPred = StdErrPred_a1 DF = DF_a1 tValue = tValue_a1
			  Probt = Probt_a1 Alpha = Alpha_a1 Lower = Lower_a1 Upper = Upper_a1));
run;
data cort.mixedeffect_b1;
	set cort.mixedeffect_b1 (keep = M2ID Pred StdErrPred DF tValue Probt Alpha Lower Upper
	rename = (Pred = Pred_b1 StdErrPred = StdErrPred_b1 DF = DF_b1 tValue = tValue_b1
			  Probt = Probt_b1 Alpha = Alpha_b1 Lower = Lower_b1 Upper = Upper_b1));
run;
* merge mixed effect datasets;
data cort.mixedeffects;
	merge cort.mixedeffect_a0 cort.mixedeffect_a1 cort.mixedeffect_b1;
	by M2ID;
run;
* add fixed effect f30 to merged dataset; 
data cort.effects;
   set cort.mixedeffects;
   f30 = 0.1224;
run;
* add CORTpctime to merged dataset;
data cort.time(keep = M2ID day t CORTpctime logcort);
	set all_long2;
run;
* merge time with effects;
data cort.effects(keep = M2ID Pred_a0 Pred_a1 Pred_b1 f30 day t CORTpctime logcort);
	merge cort.effects cort.time;
	by M2ID;
run;
* rename mixed effects;
data cort.effects;
	set cort.effects(rename = (Pred_a0 = a0 Pred_a1 = a1 Pred_b1 = b1 f30 = b2));
run;
* create predictions;
data cort.predictions;
	set cort.effects;
	pred_CORTpctime = .;
	if CORTpctime <= 0 then pred_CORTpctime = a0 + a1*CORTpctime;
	else if CORTpctime > 0 then pred_CORTpctime = b1 - (b1 - ((a0 + a1*0 - b1 + b1*exp(-b2*0))/ (exp(-b2*0))))*exp(-b2*CORTpctime);
	pred_t = .;
	if CORTpctime <= 0 then pred_t = a0 + a1*t;
	else if CORTpctime > 0 then pred_t = b1 - (b1 - ((a0 + a1*0 - b1 + b1*exp(-b2*0))/ (exp(-b2*0))))*exp(-b2*t);
run;
*create average CORTpctime across days for each individual;
proc sql;
	create table cort.predictions2 as
	select *, avg(CORTpctime) as average_CORTpctime
	from cort.predictions
	group by t
	order by M2ID, day, t;
quit;
*separate linear and quadratic predictions (calculated using average_CORTpctime);
data cort.predictions3;
	set cort.predictions2;
	linear_pred = .;
	if t <= 2 then linear_pred = a0 + a1*average_CORTpctime;
	exponential_pred = .;
	if t >= 2 then exponential_pred = b1 - (b1 - ((a0 + a1*0 - b1 + b1*exp(-b2*0))/ (exp(-b2*0))))*exp(-b2*average_CORTpctime);
run;
*create random subsets of data for plotting;
data cort.subpredictions;
	set cort.predictions3;
	where (M2ID = 10019 or M2ID = 10023 or M2ID = 10047 or M2ID = 10060 or M2ID = 10098 or M2ID = 10100);
	rename M2ID = ID;
run;
*answer the following questions to determine the rowaxis values argument;
*Q: What is the sample's minimum mixed effect value for the fourth measure? A: -0.09;
proc tabulate data = cort.predictions;
	where t = 4;
	var pred_CORTpctime;
	table pred_CORTpctime * (min);
run;
*Q: What is the sample's maximum mixed effect value for the second measure? A: 4.49;
proc tabulate data = cort.predictions;
	where t = 2;
	var pred_CORTpctime;
	table pred_CORTpctime * (max);
run;
*plot predictions based on variable t;
proc sgpanel data = cort.subpredictions; * noautolegend;
	*where day = 2;
	panelby ID / columns=3 spacing=5 /*novarname*/;
	styleattrs datacolors=(GRAY4F);
	*series x = t y = pred_t;
	scatter x = t y = pred_t / name = "Predicted" legendlabel = "Predicted" markerattrs=(symbol=circlefilled size = 4);
	scatter x = t y = logcort / name = "Measured" legendlabel = "Measured" markerattrs=(symbol=X);
	rowaxis label = "Measured vs. Predicted Log-Cortisol" values = (-0.10 to 4.5);
	colaxis label = "Time Since Waking (hours)";
	*title "Predicted Trajectories for a Random Subsample of Six Individuals";
	keylegend "Predicted" "Measured";
run;
*plot trajectories based on variable average_CORTpctime;
proc sgpanel data = cort.subpredictions; * noautolegend;
	*where day = 2;
	panelby ID / columns=3 spacing=5 /*novarname*/;
	styleattrs datacolors=(GRAY4F);
	series x = average_CORTpctime y = linear_pred / group = t;
	*series x = average_CORTpctime y = exponential_pred / group = t;
	pbspline x = average_CORTpctime y = exponential_pred;
	*loess x = average_CORTpctime y = exponential_pred;
	scatter x = average_CORTpctime y = linear_pred / name = "Predicted" legendlabel = "Predicted" markerattrs=(symbol=circlefilled size = 4);
	scatter x = average_CORTpctime y = exponential_pred / name = "Predicted" legendlabel = "Predicted" markerattrs=(symbol=circlefilled size = 4);
	scatter x = CORTpctime y = logcort / name = "Measured" legendlabel = "Measured" markerattrs=(symbol=X);
	rowaxis label = "Measured vs. Predicted Log-Cortisol" values = (-0.10 to 4.5);
	colaxis label = "Time Since Waking (hours)";
	*title "Predicted Trajectories Taking Time of Measurement into Account for a Random Subsample of Six Individuals on Day 2";
	title " ";
	keylegend "Predicted" "Measured";
run;
***** TRAJECTORIES FOR 1 INDIVIDUAL;
*create data for a single individual;
data cort.subpredictions2;
	set cort.subpredictions;
	where ID = 10047;
run;
* transpose data from long to wide;
data cort.wide;
	array tvar[4]					t1-t4;
	array CORTpctimevar[4]			CORTpctime1-CORTpctime4;
	array logcortvar[4]				logcort1-logcort4;
	array pred_CORTpctimevar[4]		pred_CORTpctime1-pred_CORTpctime4;
	array pred_tvar[4]				pred_t1-pred_t4;
	array average_CORTpctimevar[4]	average_CORTpctime1-average_CORTpctime4;
	array linear_predvar[4]			linear_pred1-linear_pred4;
	array exponential_predvar[4]	exponential_pred1-exponential_pred4;

	do i = 1 to 4 until (last.day); set cort.subpredictions2; by day;
	tvar[i] = 						t;
	CORTpctimevar[i] = 				CORTpctime;
	logcortvar[i] = 				logcort;
	pred_CORTpctimevar[i] = 		pred_CORTpctime;
	pred_tvar[i] =					pred_t;
	average_CORTpctimevar[i] =		average_CORTpctime;
	linear_predvar[i] =				linear_pred;
	exponential_predvar[i] =		exponential_pred;
	end;
keep ID a0 a1 b1 b2 CORTpctime1-CORTpctime4 t1-t4 day logcort1-logcort4;
run;
* add new variables;
data cort.wide2;
	set cort.wide(rename = (CORTpctime3 = CORTpctime12 CORTpctime4 = CORTpctime22 logcort3 = logcort12 logcort4 = logcort22));
	array new1(9) CORTpctime3-CORTpctime11;
	do i = 1 to 9;
		new1(i) = CORTpctime2;
	end;
	array new2(9) CORTpctime13-CORTpctime21;
	do j = 1 to 9;
		new2(j) = CORTpctime12;
	end;
	array new3(22) linearpred1-linearpred22;
	do k = 1 to 22;
		new3(k) = .;
	end;
	array new4(22) exponpred1-exponpred22;
	do m = 1 to 22;
		new4(m) = .;
	end;
	array new5(22) t1-t22;
	do p = 1 to 22;
		new5(p) = .;
	end;
	array new6(9) logcort3-logcort11;
	do q = 1 to 9;
		new6(q) = .;
	end;
	array new7(9) logcort13-logcort21;
	do t = 1 to 9;
		new7(t) = .;
	end;
drop i j k m p q t; 
run;
* revalue new variables;
data cort.wide3;
	set cort.wide2;
	CORTpctime3 = CORTpctime2 + (1*((CORTpctime12 - CORTpctime2)/10));
	CORTpctime4 = CORTpctime2 + (2*((CORTpctime12 - CORTpctime2)/10));
	CORTpctime5 = CORTpctime2 + (3*((CORTpctime12 - CORTpctime2)/10));
	CORTpctime6 = CORTpctime2 + (4*((CORTpctime12 - CORTpctime2)/10));
	CORTpctime7 = CORTpctime2 + (5*((CORTpctime12 - CORTpctime2)/10));
	CORTpctime8 = CORTpctime2 + (6*((CORTpctime12 - CORTpctime2)/10));
	CORTpctime9 = CORTpctime2 + (7*((CORTpctime12 - CORTpctime2)/10));
	CORTpctime10 = CORTpctime2 + (8*((CORTpctime12 - CORTpctime2)/10));
	CORTpctime11 = CORTpctime2 + (9*((CORTpctime12 - CORTpctime2)/10));

	CORTpctime13 = CORTpctime12 + (1*((CORTpctime22 - CORTpctime12)/10));
	CORTpctime14 = CORTpctime12 + (2*((CORTpctime22 - CORTpctime12)/10));
	CORTpctime15 = CORTpctime12 + (3*((CORTpctime22 - CORTpctime12)/10));
	CORTpctime16 = CORTpctime12 + (4*((CORTpctime22 - CORTpctime12)/10));
	CORTpctime17 = CORTpctime12 + (5*((CORTpctime22 - CORTpctime12)/10));
	CORTpctime18 = CORTpctime12 + (6*((CORTpctime22 - CORTpctime12)/10));
	CORTpctime19 = CORTpctime12 + (7*((CORTpctime22 - CORTpctime12)/10));
	CORTpctime20 = CORTpctime12 + (8*((CORTpctime22 - CORTpctime12)/10));
	CORTpctime21 = CORTpctime12 + (9*((CORTpctime22 - CORTpctime12)/10));

	t1 =1; t2 = 2; t3 = 3; t4 = 4; t5 = 5; t6 = 6; t7 = 7; t8 = 8; t9 =9; 
	t10 = 10; t11 = 11; t12 = 12; t13 = 13; t14 = 14; t15 = 15; t16 = 16; 
	t17 = 17; t18 = 18; t19 = 19; t20 = 20; t21 = 21; t22 = 22;
run;
* transpose wide to long;
data cort.long;
	set cort.wide3;
 	array CORTpctimevar[22]	  		CORTpctime1-CORTpctime22;
 	array linearpredvar[22]	  		linearpred1-linearpred22;
 	array exponpredvar[22]			exponpred1-exponpred22;
	array tvar[22]					t1-t22;
	array logcortvar[22]			logcort1-logcort22;

	do i = 1 to 22;
	CORTpctime = CORTpctimevar [i]; 
	linearpred = linearpredvar [i]; 
	exponpred = exponpredvar [i]; 
	t = tvar [i];
	logcort = logcortvar [i];
	output; end;

	drop i CORTpctime1-CORTpctime22 linearpred1-linearpred22 exponpred1-exponpred22 t1-t22 logcort1-logcort22;
run;
*create average CORTpctime across days for the individual;
proc sql;
	create table cort.longpred as
	select *, avg(CORTpctime) as average_CORTpctime
	from cort.long
	group by t
	order by ID, day, t;
quit;
* separate linear and quadratic predictions (calculated using average_CORTpctime);
data cort.longpred2;
	set cort.longpred;
	if (t <= 2) & (day = "2") then linearpred = a0 + a1*average_CORTpctime;
	if (t >= 2) & (day = "2") then exponpred = b1 - (b1 - ((a0 + a1*0 - b1 + b1*exp(-b2*0))/ (exp(-b2*0))))*exp(-b2*average_CORTpctime);
run;
* plot a single individual's data;
proc sgplot data = cort.longpred2 noautolegend;
	styleattrs datacolors=(GRAY4F);
	where ID = 17671;
	*scatter x = CORTpctime y = logcort / name = "Measures" legendlabel = "Measures" markerattrs=(symbol=CircleFilled size = 3);
	series x = average_CORTpctime y = linearpred / lineattrs=(pattern=Solid color = black);
	series x = average_CORTpctime y = exponpred / lineattrs=(pattern=Solid color = black);
	xaxis label = "Hours since awakening" values = (-3 to 21 by 3);
	yaxis label = "Predicted ln(cortisol) nmol/l" values = (1 to 3.5 by .5);
run;
***** TRAJECTORIES FOR 9 INDIVIDUALS;
* create random subsets of data for plotting;
data cort.subpredictions2;
	set cort.predictions3;
	where (M2ID = 10047 or M2ID = 10100 or M2ID = 10107 or M2ID = 10134 or 
		   M2ID = 10158 or M2ID = 10174 or M2ID = 10186 or M2ID = 10230 or M2ID = 10308);
	rename M2ID = ID;
run;
PROC SORT DATA = cort.subpredictions2 OUT = cort.subpredictions2; BY day; run;
* transpose data from long to wide;
data cort.wide;
	array tvar[4]					t1-t4;
	array CORTpctimevar[4]			CORTpctime1-CORTpctime4;
	array logcortvar[4]				logcort1-logcort4;
	array pred_CORTpctimevar[4]		pred_CORTpctime1-pred_CORTpctime4;
	array pred_tvar[4]				pred_t1-pred_t4;
	array average_CORTpctimevar[4]	average_CORTpctime1-average_CORTpctime4;
	array linear_predvar[4]			linear_pred1-linear_pred4;
	array exponential_predvar[4]	exponential_pred1-exponential_pred4;
	array IDvar[4]					ID1-ID4;

	do i = 1 to 4 until (last.day); set cort.subpredictions2; by day;
	tvar[i] = 						t;
	CORTpctimevar[i] = 				CORTpctime;
	logcortvar[i] = 				logcort;
	pred_CORTpctimevar[i] = 		pred_CORTpctime;
	pred_tvar[i] =					pred_t;
	average_CORTpctimevar[i] =		average_CORTpctime;
	linear_predvar[i] =				linear_pred;
	exponential_predvar[i] =		exponential_pred;
	IDvar[i] = 						ID;
	end;
keep ID a0 a1 b1 b2 CORTpctime1-CORTpctime4 t1-t4 day logcort1-logcort4;
run;
PROC SORT DATA = cort.wide OUT = cort.wide; BY ID; run;
* add new variables;
data cort.wide2;
	set cort.wide(rename = (CORTpctime3 = CORTpctime12 CORTpctime4 = CORTpctime22 logcort3 = logcort12 logcort4 = logcort22));
	array new1(9) CORTpctime3-CORTpctime11;
	do i = 1 to 9;
		new1(i) = CORTpctime2;
	end;
	array new2(9) CORTpctime13-CORTpctime21;
	do j = 1 to 9;
		new2(j) = CORTpctime12;
	end;
	array new3(22) linearpred1-linearpred22;
	do k = 1 to 22;
		new3(k) = .;
	end;
	array new4(22) exponpred1-exponpred22;
	do m = 1 to 22;
		new4(m) = .;
	end;
	array new5(22) t1-t22;
	do p = 1 to 22;
		new5(p) = .;
	end;
	array new6(9) logcort3-logcort11;
	do q = 1 to 9;
		new6(q) = .;
	end;
	array new7(9) logcort13-logcort21;
	do t = 1 to 9;
		new7(t) = .;
	end;
drop i j k m p q t; 
run;
* revalue new variables;
data cort.wide3;
	set cort.wide2;
	CORTpctime3 = CORTpctime2 + (1*((CORTpctime12 - CORTpctime2)/10));
	CORTpctime4 = CORTpctime2 + (2*((CORTpctime12 - CORTpctime2)/10));
	CORTpctime5 = CORTpctime2 + (3*((CORTpctime12 - CORTpctime2)/10));
	CORTpctime6 = CORTpctime2 + (4*((CORTpctime12 - CORTpctime2)/10));
	CORTpctime7 = CORTpctime2 + (5*((CORTpctime12 - CORTpctime2)/10));
	CORTpctime8 = CORTpctime2 + (6*((CORTpctime12 - CORTpctime2)/10));
	CORTpctime9 = CORTpctime2 + (7*((CORTpctime12 - CORTpctime2)/10));
	CORTpctime10 = CORTpctime2 + (8*((CORTpctime12 - CORTpctime2)/10));
	CORTpctime11 = CORTpctime2 + (9*((CORTpctime12 - CORTpctime2)/10));

	CORTpctime13 = CORTpctime12 + (1*((CORTpctime22 - CORTpctime12)/10));
	CORTpctime14 = CORTpctime12 + (2*((CORTpctime22 - CORTpctime12)/10));
	CORTpctime15 = CORTpctime12 + (3*((CORTpctime22 - CORTpctime12)/10));
	CORTpctime16 = CORTpctime12 + (4*((CORTpctime22 - CORTpctime12)/10));
	CORTpctime17 = CORTpctime12 + (5*((CORTpctime22 - CORTpctime12)/10));
	CORTpctime18 = CORTpctime12 + (6*((CORTpctime22 - CORTpctime12)/10));
	CORTpctime19 = CORTpctime12 + (7*((CORTpctime22 - CORTpctime12)/10));
	CORTpctime20 = CORTpctime12 + (8*((CORTpctime22 - CORTpctime12)/10));
	CORTpctime21 = CORTpctime12 + (9*((CORTpctime22 - CORTpctime12)/10));

	t1 =1; t2 = 2; t3 = 3; t4 = 4; t5 = 5; t6 = 6; t7 = 7; t8 = 8; t9 =9; 
	t10 = 10; t11 = 11; t12 = 12; t13 = 13; t14 = 14; t15 = 15; t16 = 16; 
	t17 = 17; t18 = 18; t19 = 19; t20 = 20; t21 = 21; t22 = 22;
run;
* transpose wide to long;
data cort.long;
	set cort.wide3;
 	array CORTpctimevar[22]	  		CORTpctime1-CORTpctime22;
 	array linearpredvar[22]	  		linearpred1-linearpred22;
 	array exponpredvar[22]			exponpred1-exponpred22;
	array tvar[22]					t1-t22;
	array logcortvar[22]			logcort1-logcort22;

	do i = 1 to 22;
	CORTpctime = CORTpctimevar [i]; 
	linearpred = linearpredvar [i]; 
	exponpred = exponpredvar [i]; 
	t = tvar [i];
	logcort = logcortvar [i];
	output; end;

	drop i CORTpctime1-CORTpctime22 linearpred1-linearpred22 exponpred1-exponpred22 t1-t22 logcort1-logcort22;
run;
* create average CORTpctime across days for the individual;
proc sql;
	create table cort.longpred as
	select *, avg(CORTpctime) as average_CORTpctime
	from cort.long
	group by t
	order by ID, day, t;
quit;
* separate linear and quadratic predictions (calculated using average_CORTpctime);
data cort.longpred2;
	set cort.longpred;
	if (t <= 2) & (day = "2") then linearpred = a0 + a1*average_CORTpctime;
	if (t >= 2) & (day = "2") then exponpred = b1 - (b1 - ((a0 + a1*0 - b1 + b1*exp(-b2*0))/ (exp(-b2*0))))*exp(-b2*average_CORTpctime);
run;
* plot 9 individual trajectories (with labels);
proc sgpanel data = cort.longpred2; * noautolegend;
	*where day = 2;
	panelby ID / columns=3 spacing=5 /*novarname*/;
	styleattrs datacolors=(GRAY4F);

	scatter x = CORTpctime y = logcort / name = "Measured" legendlabel = "Measured" markerattrs=(symbol=CircleFilled size = 3);
	series x = average_CORTpctime y = linearpred / name = "Predicted" legendlabel = "Predicted" lineattrs=(pattern=MediumDash) CurveLabel = "Linear" CURVELABELATTRS=(Family="Arial" Size=8);
	series x = average_CORTpctime y = exponpred / name = "Predicted" legendlabel = "Predicted" lineattrs=(pattern=Solid) CurveLabel = "Exponential" CURVELABELATTRS=(Family="Arial" Size=8);

	rowaxis label = "Measured vs. Predicted Log-Cortisol" values = (-0.10 to 4.5);
	colaxis label = "Time Since Waking (hours)";
	*title "Predicted Trajectories Taking Time of Measurement into Account for a Random Subsample of Six Individuals on Day 2";
	title " ";
	keylegend "Predicted" "Measured";
run;
* plot 9 individual trajectories (without labels);
proc sgpanel data = cort.longpred2; * noautolegend;
	*where day = 2;
	panelby ID / columns=3 spacing=5 /*novarname*/;
	styleattrs datacolors=(GRAY4F);

	scatter x = average_CORTpctime y = logcort / name = "Measured" legendlabel = "Measured" markerattrs=(symbol=CircleFilled size = 3);
	series x = average_CORTpctime y = linearpred / name = "Predicted" legendlabel = "Predicted" lineattrs=(pattern=Solid);
	series x = average_CORTpctime y = exponpred / name = "Predicted" legendlabel = "Predicted" lineattrs=(pattern=Solid);

	rowaxis label = "Measured vs. Predicted Log-Cortisol" values = (-0.10 to 4.5);
	colaxis label = "Time Since Waking (hours)";
	*title "Predicted Trajectories Taking Time of Measurement into Account for a Random Subsample of Six Individuals on Day 2";
	title " ";
	keylegend "Predicted" "Measured";
run;

***** COMPARING TRAJECTORIES FOR 2 GROUPS OF 9 INDIVIDUALS;
* create first random subsets of data for plotting;
data cort.subpredictions3;
	set cort.predictions3;
	where (M2ID = 18148 or M2ID = 17976 or M2ID = 15837 or M2ID = 15423 or 
		   M2ID = 12264 or M2ID = 11970 or M2ID = 10537 or M2ID = 10265 or M2ID = 18954);
	rename M2ID = ID;
run;
PROC SORT DATA = cort.subpredictions3 OUT = cort.subpredictions3; BY day; run;





* HERE!!!!;
* create a new dataset with 4 time points for each individual;
data cort.ID3;
input ID times;
do i = 1 to times;
output;
end;
cards;
18148 16
17976 16
15837 16
15423 16
12264 16
11970 16
10537 16
10265 16
18954 16
;;;;
run;
data cort.new3 (drop = times i);
	set cort.ID3;
	if t_cmplt >= 4 then t_cmplt = 0;
	t_cmplt+1;
run;
PROC SORT DATA = cort.new3 OUT = cort.new3_sort; BY ID t_cmplt; run;
PROC SORT DATA = cort.subpredictions3 OUT = cort.subpredictions3_sort; BY ID t; run;
data cort.subpred3_merged;
	merge cort.subpredictions3_sort cort.new3_sort;
	by ID;
run;
data cort.subpred3_merged;
	merge cort.subpredictions3_sort cort.new3_sort (in = in2);
	by ID t_cmplt;
	if in2;
run;
proc freq data = cort.subpred3_merged;
table t_cmplt;
run;






















PROC SORT DATA = cort.subpredictions3 OUT = cort.subpred3_merged; BY day; run;
* transpose data from long to wide;
data cort.wide3;
	array tvar[4]					t1-t4;
	array CORTpctimevar[4]			CORTpctime1-CORTpctime4;
	array logcortvar[4]				logcort1-logcort4;
	array pred_CORTpctimevar[4]		pred_CORTpctime1-pred_CORTpctime4;
	array pred_tvar[4]				pred_t1-pred_t4;
	array average_CORTpctimevar[4]	average_CORTpctime1-average_CORTpctime4;
	array linear_predvar[4]			linear_pred1-linear_pred4;
	array exponential_predvar[4]	exponential_pred1-exponential_pred4;
	array IDvar[4]					ID1-ID4;

	do i = 1 to 4 until (last.day); set cort.subpred3_merged; by day;
	tvar[i] = 						t;
	CORTpctimevar[i] = 				CORTpctime;
	logcortvar[i] = 				logcort;
	pred_CORTpctimevar[i] = 		pred_CORTpctime;
	pred_tvar[i] =					pred_t;
	average_CORTpctimevar[i] =		average_CORTpctime;
	linear_predvar[i] =				linear_pred;
	exponential_predvar[i] =		exponential_pred;
	IDvar[i] = 						ID;
	end;
keep ID a0 a1 b1 b2 CORTpctime1-CORTpctime4 t1-t4 day logcort1-logcort4;
run;
PROC SORT DATA = cort.wide3 OUT = cort.wide3; BY ID; run;
* add new variables;
data cort.wide2;
	set cort.wide(rename = (CORTpctime3 = CORTpctime12 CORTpctime4 = CORTpctime22 logcort3 = logcort12 logcort4 = logcort22));
	array new1(9) CORTpctime3-CORTpctime11;
	do i = 1 to 9;
		new1(i) = CORTpctime2;
	end;
	array new2(9) CORTpctime13-CORTpctime21;
	do j = 1 to 9;
		new2(j) = CORTpctime12;
	end;
	array new3(22) linearpred1-linearpred22;
	do k = 1 to 22;
		new3(k) = .;
	end;
	array new4(22) exponpred1-exponpred22;
	do m = 1 to 22;
		new4(m) = .;
	end;
	array new5(22) t1-t22;
	do p = 1 to 22;
		new5(p) = .;
	end;
	array new6(9) logcort3-logcort11;
	do q = 1 to 9;
		new6(q) = .;
	end;
	array new7(9) logcort13-logcort21;
	do t = 1 to 9;
		new7(t) = .;
	end;
drop i j k m p q t; 
run;
* revalue new variables;
data cort.wide3;
	set cort.wide2;
	CORTpctime3 = CORTpctime2 + (1*((CORTpctime12 - CORTpctime2)/10));
	CORTpctime4 = CORTpctime2 + (2*((CORTpctime12 - CORTpctime2)/10));
	CORTpctime5 = CORTpctime2 + (3*((CORTpctime12 - CORTpctime2)/10));
	CORTpctime6 = CORTpctime2 + (4*((CORTpctime12 - CORTpctime2)/10));
	CORTpctime7 = CORTpctime2 + (5*((CORTpctime12 - CORTpctime2)/10));
	CORTpctime8 = CORTpctime2 + (6*((CORTpctime12 - CORTpctime2)/10));
	CORTpctime9 = CORTpctime2 + (7*((CORTpctime12 - CORTpctime2)/10));
	CORTpctime10 = CORTpctime2 + (8*((CORTpctime12 - CORTpctime2)/10));
	CORTpctime11 = CORTpctime2 + (9*((CORTpctime12 - CORTpctime2)/10));

	CORTpctime13 = CORTpctime12 + (1*((CORTpctime22 - CORTpctime12)/10));
	CORTpctime14 = CORTpctime12 + (2*((CORTpctime22 - CORTpctime12)/10));
	CORTpctime15 = CORTpctime12 + (3*((CORTpctime22 - CORTpctime12)/10));
	CORTpctime16 = CORTpctime12 + (4*((CORTpctime22 - CORTpctime12)/10));
	CORTpctime17 = CORTpctime12 + (5*((CORTpctime22 - CORTpctime12)/10));
	CORTpctime18 = CORTpctime12 + (6*((CORTpctime22 - CORTpctime12)/10));
	CORTpctime19 = CORTpctime12 + (7*((CORTpctime22 - CORTpctime12)/10));
	CORTpctime20 = CORTpctime12 + (8*((CORTpctime22 - CORTpctime12)/10));
	CORTpctime21 = CORTpctime12 + (9*((CORTpctime22 - CORTpctime12)/10));

	t1 =1; t2 = 2; t3 = 3; t4 = 4; t5 = 5; t6 = 6; t7 = 7; t8 = 8; t9 =9; 
	t10 = 10; t11 = 11; t12 = 12; t13 = 13; t14 = 14; t15 = 15; t16 = 16; 
	t17 = 17; t18 = 18; t19 = 19; t20 = 20; t21 = 21; t22 = 22;
run;
* transpose wide to long;
data cort.long;
	set cort.wide3;
 	array CORTpctimevar[22]	  		CORTpctime1-CORTpctime22;
 	array linearpredvar[22]	  		linearpred1-linearpred22;
 	array exponpredvar[22]			exponpred1-exponpred22;
	array tvar[22]					t1-t22;
	array logcortvar[22]			logcort1-logcort22;

	do i = 1 to 22;
	CORTpctime = CORTpctimevar [i]; 
	linearpred = linearpredvar [i]; 
	exponpred = exponpredvar [i]; 
	t = tvar [i];
	logcort = logcortvar [i];
	output; end;

	drop i CORTpctime1-CORTpctime22 linearpred1-linearpred22 exponpred1-exponpred22 t1-t22 logcort1-logcort22;
run;
* create average CORTpctime across days for the individual;
proc sql;
	create table cort.longpred as
	select *, avg(CORTpctime) as average_CORTpctime
	from cort.long
	group by t
	order by ID, day, t;
quit;
* separate linear and quadratic predictions (calculated using average_CORTpctime);
data cort.longpred2;
	set cort.longpred;
	if (t <= 2) & (day = "2") then linearpred = a0 + a1*average_CORTpctime;
	if (t >= 2) & (day = "2") then exponpred = b1 - (b1 - ((a0 + a1*0 - b1 + b1*exp(-b2*0))/ (exp(-b2*0))))*exp(-b2*average_CORTpctime);
run;
* plot 9 individual trajectories (with labels);
proc sgpanel data = cort.longpred2; * noautolegend;
	*where day = 2;
	panelby ID / columns=3 spacing=5 /*novarname*/;
	styleattrs datacolors=(GRAY4F);

	scatter x = CORTpctime y = logcort / name = "Measured" legendlabel = "Measured" markerattrs=(symbol=CircleFilled size = 3);
	series x = average_CORTpctime y = linearpred / name = "Predicted" legendlabel = "Predicted" lineattrs=(pattern=MediumDash) CurveLabel = "Linear" CURVELABELATTRS=(Family="Arial" Size=8);
	series x = average_CORTpctime y = exponpred / name = "Predicted" legendlabel = "Predicted" lineattrs=(pattern=Solid) CurveLabel = "Exponential" CURVELABELATTRS=(Family="Arial" Size=8);

	rowaxis label = "Measured vs. Predicted Log-Cortisol" values = (-0.10 to 4.5);
	colaxis label = "Time Since Waking (hours)";
	*title "Predicted Trajectories Taking Time of Measurement into Account for a Random Subsample of Six Individuals on Day 2";
	title " ";
	keylegend "Predicted" "Measured";
run;
* plot 9 individual trajectories (without labels);
proc sgpanel data = cort.longpred2; * noautolegend;
	*where day = 2;
	panelby ID / columns=3 spacing=5 /*novarname*/;
	styleattrs datacolors=(GRAY4F);

	scatter x = average_CORTpctime y = logcort / name = "Measured" legendlabel = "Measured" markerattrs=(symbol=CircleFilled size = 3);
	series x = average_CORTpctime y = linearpred / name = "Predicted" legendlabel = "Predicted" lineattrs=(pattern=Solid);
	series x = average_CORTpctime y = exponpred / name = "Predicted" legendlabel = "Predicted" lineattrs=(pattern=Solid);

	rowaxis label = "Measured vs. Predicted Log-Cortisol" values = (-0.10 to 4.5);
	colaxis label = "Time Since Waking (hours)";
	*title "Predicted Trajectories Taking Time of Measurement into Account for a Random Subsample of Six Individuals on Day 2";
	title " ";
	keylegend "Predicted" "Measured";
run;



data cort.subpredictions4;
	set cort.predictions3;
	where (M2ID = 18954 or M2ID = 18266 or M2ID = 18214 or M2ID = 18126 or 
		   M2ID = 17979 or M2ID = 17754 or M2ID = 17671 or M2ID = 17646 or M2ID = 17561);
	rename M2ID = ID;
run;
PROC SORT DATA = cort.subpredictions4 OUT = cort.subpredictions4; BY day; run;



