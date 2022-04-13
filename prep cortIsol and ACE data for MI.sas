*****************
*** READ IN DATA;
****************;

* MIDUS 2 Biomarker Project; 
proc import datafile="C:\Users\mcraft\Desktop\MIDUS 2 Data\29282-0001-Data.sav" out=Da29282p1 dbms = sav replace; run;  
* MIDUS 2 Aggregate Project;
proc import datafile= "C:\Users\mcraft\Desktop\MIDUS 2 Data\04652-0001-Data.sav" out=Da4652p1 dbms = sav replace; run; 
* MIDUS 2 Daily Stress Project;
proc import datafile= "C:\Users\mcraft\Desktop\MIDUS 2 Data\26841-0001-Data.sav" out=Da26841p1 dbms = sav replace; run; 
* MIDUS 1;
* Double click 02760-0001-Data SAS file to open; 

*************************
*** START DATA WRANGLING;
************************;

* MIDUS 2 Biomarker contains ACE indicator 7;
data midus2_biomrk; 
	set Da29282p1; 
	keep M2FAMNUM m2id SAMPLMAJ B4ZCOMPM B4ZCOMPY b4qma_d b4qma_a b4qcesd b4qta_ax b4qsa_sa 
	B4O4B B4O5 B4O4A B4BCRP B4BFGN B4BSESEL B4BSICAM B4BIL6 B4QCT_SA; 
run; 
PROC SORT DATA = midus2_biomrk OUT = midus2_biomrk; 
	BY M2FAMNUM m2id;
run;
data midus2_biomrk; 
	set midus2_biomrk;
	if      B4QCT_SA >5 then sexabuse=1;
	else if B4QCT_SA =5 then sexabuse = 0;
	else if B4QCT_SA =. then sexabuse = .;
	m2_biomrk = 1;
run;
* Note: background variables measured in the same longitudinal wave as daily cortisol meaures from the Daily Stress Project;
data midus2_agg; 
	set Da4652p1; 
	keep SAMPLMAJ M2FAMNUM m2id B1SBMI B1SA11G B1SA11x b1pf1 B1PB13 B1SNEGPA B1SBMI b1sa11g b1sa11x
	b1sa12b b1pb1 B1PA39 B1PIDATE_MO B1PIDATE_YR b1panxie b1pdepaf b1pa64 b1pa75 b1pa88H B1SPOSPA 
	B1SNEGPA B1SPWBG2 B1SPWBS2 b1pb1 b1pf7a b1pf7b b1pf7c b1pf7d B1PB19 B1PBWORK B1STINC1;
run;
data midus2_agg;
	set midus2_agg;
	education=b1pb1;
	race1 =  B1PF7A; 
	race2 =  B1PF7B;
	* Define education by no high school/GED, HS/GED, or 4-year degree or higher;
	if education = .                            then do; nohighschool = .; highschoolGED =.;  fouryrcollegeplus = .; end; 
	else if education <=3                       then do; nohighschool = 1; highschoolGED = 0; fouryrcollegeplus  = 0; end;
	else if (education >= 4 and education <= 8) then do; nohighschool = 0; highschoolGED = 1; fouryrcollegeplus  = 0; end;
	else if education >= 9                      then do; nohighschool = 0; highschoolGED = 0; fouryrcollegeplus  = 1; end;
	else if (education = 97 or education = 98)  then do; nohighschool = .; highschoolGED = .; fouryrcollegeplus  = .; end;
	HSGEDplus = .;
	if nohighschool = 1					then HSGEDplus = 0;
	else if nohighschool = 0			then HSGEDplus = 1;
	RaceWhite=.;
    if race1 = 1 and race2 = 9      	then RaceWhite = 1; 
    else if race1 > 1 and race2 < 9  	then RaceWhite = 0; 
    else if race1 = 7 or race1 = 8      then RaceWhite = .;
	RaceBlack=.;
    if race1 = 2 or race2 = 2           then RaceBlack = 1; 
    else if race1 ^= 2 or race2 ^=2  	then RaceBlack = 0; 
    else if race1 = 7 or race1 = 8   	then RaceBlack = .;
	RaceNotWhite=.;
    if RaceWhite=1 						then RaceNotWhite = 0;
	else if RaceWhite=0 				then RaceNotWhite = 1;
	smoking = .;
	if B1PA39 = 1                    then smoking = 1;
	else if B1PA39 = 2 or B1PA39 = 9 or B1PA39 = . then smoking = 0;
	Hispanic=.;
    if B1PF1 = 1                     then Hispanic=0; 
    else if B1PF1 >1                 then Hispanic=1;
    else if B1PF1 = 97 or B1PF1 = 98 then Hispanic=.; 
	NatAm=.;
    if b1pf7a = 3                    then NatAm = 1; 
    else if b1pf7a ^=3               then NatAm =0;
    else if b1pf7a  =7 or b1pf7a =8  then NatAm =.;
	Income = B1STINC1;
	if B1STINC1 = 9999998 			 then Income = .;
	Logincome = log(Income + 1);
	m2_agg = 1;
run; 
PROC SORT DATA = midus2_agg OUT = midus2_agg; 
	BY M2FAMNUM m2id; 
run;
data midus2_agg; 
	set midus2_agg; 
	aggmonth = B1PIDATE_MO; 
	aggyear = B1PIDATE_YR; 
run;
PROC SORT DATA = midus2_agg OUT = midus2_agg; 
	BY M2FAMNUM m2id; 
run;
* MIDUS 1 contains ACE indicators 1-6;
data midus1; 
	set Da2760p1; 
	keep SAMPLMAJ M2FAMNUM m2id A1PC14 A1PC8 A1PC2 A1PCA3 A1PCA1 A1PCA2 A1SE17A A1SE17B A1SE17F A1SE17G A1SE17K A1SE17L
	A1PDEPRE A1SPOSAF A1SNEGAF A1PANXIE A1SSATIS A1SUSEMH A1SA40E A1PDEPRE A1SA10K;
run;
data midus1;
	set midus1;
	posaff = A1SPOSAF;
	if A1SPOSAF = -1 		then posaff = .;
	else if A1SPOSAF = 9 	then posaff = .;
	negaff = A1SNEGAF;
	if A1SNEGAF = -1 		then negaff = .;
	else if A1SNEGAF = 9 	then negaff = .;
	anxiety = A1PANXIE;
	if A1PANXIE = -1 		then anxiety = .;
	else if A1PANXIE = 9 	then anxiety = .;
	lifesat = A1SSATIS;
	if A1SSATIS = -1 		then lifesat = .;
	else if A1SSATIS = 99 	then lifesat = .;
	mhprofessional = A1SUSEMH;
	if A1SUSEMH = -1 		then mhprofessional = .;
	else if A1SUSEMH = 999 	then mhprofessional = .;
	ownmeds = .;
	if A1SA40E = 1 			then ownmeds = 1;
	else if A1SA40E = 2 	then ownmeds = 0;
	else if A1SA40E = . 	then ownmeds = .;
	dameds = .;
	if A1SA10K = 1 			then dameds = 1;
	else if A1SA10K = 2 	then dameds = 0;
	else if A1SA10K = . 	then dameds = .;
	m1 = 1;
run; 
PROC SORT DATA = midus1 OUT = midus1; 
	BY M2FAMNUM m2id; 
run;
* Create indicators 1-6 from Midlife in the United States (MIDUS 1), 1995-1996 (ICPSR 2760)
(1) childhood financial status (i.e., family on welfare) = A1PC14
(2) parental education (i.e., less than 12 years) = either of these: A1PC8 (female) A1PC2 (male)
(3) parental divorce = A1PCA3 
(4) parental death = either of these: A1PCA1 (female) A1PCA2 (male)
(5) emotional abuse = either of these: A1SE17A  (female) A1SE17B (male)
(6) physical abuse = any of these: A1SE17F (female) A1SE17G (male) A1SE17K (severe, female) A1SE17L (severe, male);
DATA temp; 
  	MERGE midus2_biomrk midus2_agg midus1; 
  	BY M2FAMNUM m2id; 
  	welfare=.;
	if  A1PC14=1   	   then welfare=1; 
    else if A1PC14 = 2 then welfare=0;
    else if A1PC14 =.  then welfare=.; 
	momeduc=.;
	if A1PC8 <=3                                  	  then momeduc=1; 
    else if A1PC8 >3 and A1PC8 <=12                   then momeduc=0;
    else if A1PC8  = 99                               then momeduc=0;
    else if A1PC8  = 97 or A1PC8  = 98                then momeduc=.;
	dadeduc=.;
	if A1PC2 <=3                                  	  then dadeduc=1; 
    else if A1PC2 >3                                  then dadeduc=0;
    else if A1PC2  = 99                               then dadeduc=0;
    else if A1PC2  = 97 or A1PC2  = 98                then dadeduc=.;
	peducation=.;
  	if momeduc=1 or dadeduc=1 		then peducation=1; 
    else if momeduc=0 and dadeduc=0 then peducation=0;
    else if momeduc=. and dadeduc=. then peducation=.;
	pdivorce=.;
    if A1PCA3=1             	 	then pdivorce=1;
    else if A1PCA3=2 or A1PCA3=9 	then pdivorce=0;
    else if A1PCA3=7             	then pdivorce=.;
	momdeath=.;
	if A1PCA1=1              	  	then momdeath=1; 
    else if A1PCA1=2 or A1PCA1=9  	then momdeath=0;
    else if A1PCA1=7              	then momdeath=.;
	daddeath=.;
	if A1PCA2=1             	  	then daddeath=1; 
    else if A1PCA2=2 or A1PCA2=9  	then daddeath=0;
    else if A1PCA2=7              	then daddeath=.;
	pdeath=.;
	if momdeath=1 or daddeath=1  	  			  then pdeath=1; 
    else if momdeath=0 and daddeath=0 			  then pdeath=0;
    else if momdeath=. and daddeath=. 		 	  then pdeath=.;
	momemoabuse=.;
    if A1SE17A =1  or A1SE17A =2 or A1SE17A =3    then momemoabuse=1;
    else if A1SE17A =4  or A1SE17A =6             then momemoabuse=0; 
    else if A1SE17A =-1 or A1SE17A =8             then momemoabuse=.;
	dademoabuse=.;
    if A1SE17B =1  or A1SE17B =2 or A1SE17B =3    then dademoabuse=1;
    else if A1SE17B =4  or A1SE17B =6             then dademoabuse=0; 
    else if A1SE17B =-1 or A1SE17B =8             then dademoabuse=.;
	pemoabuse=.;
	if momemoabuse=1  or dademoabuse=1      	  then pemoabuse=1; 
    else if momemoabuse=0 and dademoabuse=0       then pemoabuse=0;
    else if momemoabuse=. and dademoabuse=.       then pemoabuse=.;
	mompabuse=.;
    if A1SE17F=1  or A1SE17F=2 or A1SE17F=3  	  then mompabuse=1;
    else if A1SE17F=4  or A1SE17F=6               then mompabuse=0;
    else if A1SE17F=-1 or A1SE17F=8               then mompabuse=.;
	momseverepabuse=.;
	if A1SE17K=1  or A1SE17K=2 or A1SE17K=3  	  then momseverepabuse=1;
    else if A1SE17K=4  or A1SE17K=6               then momseverepabuse=0;
    else if A1SE17K=-1 or A1SE17K=8               then momseverepabuse=.;
	momphyabuse=.;
	if mompabuse=0 and momseverepabuse=0          then momphyabuse=0;
    else if mompabuse=1 or  momseverepabuse=1     then momphyabuse=1;
    else if mompabuse=. and momseverepabuse=.     then momphyabuse=.;
    dadpabuse=.;
    if A1SE17F=1  or A1SE17F=2 or A1SE17F=3       then dadpabuse=1;
    else if A1SE17F=4  or A1SE17F=6               then dadpabuse=0;
    else if A1SE17F=-1 or A1SE17F=8 		 	  then dadpabuse=.;
	dadseverepabuse=.;
	if A1SE17K=1  or A1SE17K=2 or A1SE17K=3  	  then dadseverepabuse=1;
    else if A1SE17K=4  or A1SE17K=6               then dadseverepabuse=0;
    else if A1SE17K=-1 or A1SE17K=8 			  then dadseverepabuse=.;
	dadphyabuse=.;
	if dadpabuse=0 and dadseverepabuse=0    	  then dadphyabuse=0;
    else if dadpabuse=1 or  dadseverepabuse=1     then dadphyabuse=1;
    else if dadpabuse=. and dadseverepabuse=.     then dadphyabuse=.;
	pphyabuse=.;
	if momphyabuse=1 or dadphyabuse=1       	  then pphyabuse=1; 
	else if momphyabuse=0 and dadphyabuse=0 	  then pphyabuse=0;
RUN;
data daily; set Da26841p1; 
	fem=.; 
    if b1pgender=. then fem=.; 
	else if b1pgender=1 then fem=0; 
	else if b1pgender=2 then fem=1;
	wkend=.;
    if b2dweekd=6 then wkend=1; 
	ELSE IF b2dweekd=7 then wkend=1;
	ELSE IF b2dweekd=. then wkend=.;
	ELSE wkend=0;
	if B2DCORWT >=98 then B2DCORWT=.;
	if B2DCORAT >=98 then B2DCORAT=.;
	if B2DCORLT >=98 then B2DCORLT=.;
	if B2DCORBT >=98 then B2DCORBT=.;
run;
* 'pc' centered to a person's 2nd measure of time (B2DCORAT) which is taken as their morning peak response;
* 'wpc ' centered at the waking measure for graphing purposes; 
* time is the time lapse between assessments; 
PROC SQL; CREATE TABLE daily1 AS 
SELECT *, 
B2DCORWT - B2DCORAT as pc_corwt,    
B2DCORAT - B2DCORAT as pc_corat,
B2DCORLT - B2DCORAT as pc_corlt,
B2DCORBT - B2DCORAT as pc_corbt,
B2DCORWT - B2DCORWT as wpc_corwt,    
B2DCORAT - B2DCORWT as wpc_corat,
B2DCORLT - B2DCORWT as wpc_corlt,
B2DCORBT - B2DCORWT as wpc_corbt,
B2DCORWT - B2DCORWT as time0,    
B2DCORAT - B2DCORWT as time1,
B2DCORLT - B2DCORAT as time2,
B2DCORBT - B2DCORLT as time3
FROM daily; QUIT;
data daily1; set daily1;
	* Male binge (5+ drinks) and female binge (4+ drinks) the night before;
    bingedrink =.; 
	if      fem = 0 and B2DB3 >= 5 then bingedrink = 1; 
    else if fem = 0 and B2DB3 <5   then bingedrink = 0;
	else if fem = 1 and B2DB3 >= 4 then bingedrink = 1;
	else if fem = 1 and B2DB3 <4   then bingedrink = 0;
	else if             B2DB3 = .  then bingedrink = .;
	menstrual = .;
	if B2DB1T = 1 				   then menstrual = 1;
	else if B2DB1T ^= 1 		   then menstrual = 0;
	else if B2DB1T  = . 		   then menstrual = .;
	winter=.; spring=.; summer=.; fall=.;
	if B2DIMON = 3 or B2DIMON = 4 or B2DIMON = 5 	then spring = 1; 
	else spring = 0; 
	if B2DIMON = 6 or B2DIMON = 7 or B2DIMON = 8 	then summer = 1; 
	else summer = 0;
	if B2DIMON = 9 or B2DIMON = 10 or B2DIMON = 11 	then fall = 1; 
	else fall = 0;
	if B2DIMON = 12 or B2DIMON = 1 or B2DIMON = 2 	then winter = 1; 
	else winter = 0;
    medications = .;
	if b2dmed1 = 1 or  b2dmed2 = 1 or b2dmed3 = 1 or b2dmed4 = 1 or b2dmed5 = 1 or b2dmed6 = 1 then medications = 1;
   	else medications = 0; * If missing, assume no such meds taken;
	medicationsx = .;
	if b2dmed2 = 1 or b2dmed3 = 1 or b2dmed4 = 1 or b2dmed5 = 1 or b2dmed6 = 1 then medicationsx = 1;
   	else medicationsx = 0; * If missing, assume no such meds taken;
	daily = 1;
run;
PROC SORT DATA = daily1 OUT = daily1; 
	BY m2id; 
run;
* Convert daily stress project data file from long to wide;
data dailywide;  
	array numstressvar[8]    stress1-stress8;
	array twakevar[8]        B2DCORWT1-B2DCORWT8;
	array ta30var[8]         B2DCORAT1-B2DCORAT8;
	array tlunchvar[8]       B2DCORLT1-B2DCORLT8;
	array tbedvar[8]         B2DCORBT1-B2DCORBT8;
	array pc_twakevar[8]     pc_B2DCORWT1-pc_B2DCORWT8;
 	array pc_ta30var[8]      pc_B2DCORAT1-pc_B2DCORAT8;
 	array pc_tlunchvar[8]    pc_B2DCORLT1-pc_B2DCORLT8;
 	array pc_tbedvar[8]      pc_B2DCORBT1-pc_B2DCORBT8;
 	array wpc_twakevar[8]    wpc_B2DCORWT1-wpc_B2DCORWT8;
 	array wpc_ta30var[8]     wpc_B2DCORAT1-wpc_B2DCORAT8;
 	array wpc_tlunchvar[8]   wpc_B2DCORLT1-wpc_B2DCORLT8;
 	array wpc_tbedvar[8]     wpc_B2DCORBT1-wpc_B2DCORBT8;
 	array time0var[8]        time0_1-time0_8;
 	array time1var[8]        time1_1-time1_8;
 	array time2var[8]        time2_1-time2_8;
 	array time3var[8]        time3_1-time3_8;
 	array wcortvar [8]       B2DCORW1-B2DCORW8;
 	array a30cortvar [8]     B2DCORA1-B2DCORA8;
 	array lunchcortvar [8]   B2DCORL1-B2DCORL8;
 	array bedcortvar [8]     B2DCORB1-B2DCORB8;
 	array intvdayvar[8]      B2DDAY1-B2DDAY8;
 	array menstrualvar[8]    menstrual1-menstrual8;
 	array medicationvar[8]   medication1-medication8;
 	array medicationxvar[8]  medicationx1-medicationx8;
 	array bdrinkvar[8]       bdrink1-bdrink8;
 	array wintervar[8]       winter1-winter8;
 	array springvar[8]       spring1-spring8;
 	array summervar[8]       summer1-summer8;
 	array fallvar[8]         fall1-fall8;
 	array negaffvar[8]       negaff1-negaff8;
 	array med1var[8]         b2dmed1_1-b2dmed1_8;
 	array med2var[8]         b2dmed2_1-b2dmed2_8;
 	array med3var[8]         b2dmed3_1-b2dmed3_8;
 	array med4var[8]         b2dmed4_1-b2dmed4_8;
 	array med5var[8]         b2dmed5_1-b2dmed5_8;
 	array med6var[8]         b2dmed6_1-b2dmed6_8;
 	array wkendvar[8]        wkend1-wkend8;

 	do i = 1 to 8 until (last.m2id); set daily1; by m2id;   
	numstressvar [i] =   B2DN_STR;
	twakevar [i] =       B2DCORWT;
	ta30var [i] =        B2DCORAT;
	tlunchvar [i] =      B2DCORLT;
	tbedvar [i] =        B2DCORBT;
	pc_twakevar [i] =    pc_corwt; 
	pc_ta30var [i] =     pc_corat;
	pc_tlunchvar [i] =   pc_corlt;
	pc_tbedvar [i] =     pc_corbt;
	wpc_twakevar [i] =    wpc_corwt; 
	wpc_ta30var [i] =     wpc_corat;
	wpc_tlunchvar [i] =   wpc_corlt;
	wpc_tbedvar [i] =     wpc_corbt;
	time0var [i] = time0;
	time1var [i] = time1;
	time2var [i] = time2;
	time3var [i] = time3;
	wcortvar [i] =       B2DCORW;
	a30cortvar [i] =     B2DCORA;
	lunchcortvar [i] =   B2DCORL;
	bedcortvar [i] =     B2DCORB;
	intvdayvar [i] =     B2DDAY;  
	menstrualvar[i] =    menstrual;
	medicationvar[i] =   medications;
	medicationxvar[i] =  medicationsX;
	bdrinkvar[i] =       bingedrink;
	wintervar[i] =       winter;
	springvar[i] =       spring;
	summervar[i] =       summer;
	fallvar[i] =         fall;
	negaffvar[i] =       B2DNEGAV;
	med1var[i] = b2dmed1;
	med2var[i] = b2dmed2;
	med3var[i] = b2dmed3;
	med4var[i] = b2dmed4;
	med5var[i] = b2dmed5;
	med6var[i] = b2dmed6;
	wkendvar[i] = wkend;
	end;

	keep SAMPLMAJ M2FAMNUM m2id SAMPLMAJ B2DIMON B2DIYEAR fem B1PAGE_M2 daily wkend1-wkend8 stress1-stress8
    B2DCORWT1-B2DCORWT8 B2DCORAT1-B2DCORAT8 B2DCORLT1-B2DCORLT8 B2DCORBT1-B2DCORBT8
    B2DCORW1-B2DCORW8 B2DCORA1-B2DCORA8 B2DCORL1-B2DCORL8 B2DCORB1-B2DCORB8 B2DDAY1-B2DDAY8 menstrual1-menstrual8 
    bdrink1-bdrink8 medication1-medication8 medicationx1-medicationx8 winter1-winter8 spring1-spring8 
	summer1-summer8 fall1-fall8 negaff1-negaff8 pc_B2DCORWT1-pc_B2DCORWT8 pc_B2DCORAT1-pc_B2DCORAT8 
	pc_B2DCORLT1-pc_B2DCORLT8 pc_B2DCORBT1-pc_B2DCORBT8 wpc_B2DCORWT1-wpc_B2DCORWT8 wpc_B2DCORAT1-wpc_B2DCORAT8 
	wpc_B2DCORLT1-wpc_B2DCORLT8 wpc_B2DCORBT1-wpc_B2DCORBT8 time0_1-time0_8 time1_1-time1_8 time2_1-time2_8 
	time3_1-time3_8 B2DIMON B2DB1T B2DB3 b2dmed1_1-b2dmed1_8 b2dmed2_1-b2dmed2_8
	b2dmed3_1-b2dmed3_8 b2dmed4_1-b2dmed4_8 b2dmed5_1-b2dmed5_8 b2dmed6_1-b2dmed6_8;
run;
PROC SORT DATA = dailywide OUT = dailywide; 
	BY M2FAMNUM m2id; 
run;
data dailywide; 
	set dailywide; 
	if  SAMPLMAJ = 13 then M2FAMNUM = m2id; 
run;
PROC SORT DATA = temp OUT = temp; 
	BY M2FAMNUM m2id; 
run;
data allwide; 
	merge temp dailywide; 
	by M2FAMNUM m2id; 
run;
data allwide; set allwide;
	endocrine = .;
	if      B4O4B = 1 or  B4O5 = 1 or  B4O4A = 1 or  B1SA11G = 1 or  B1SA11x = 1  then endocrine = 1;
	else if B4O4B = . and B4O5 = . and B4O4A = . and B1SA11G = . and B1SA11x = .  then endocrine = .;
	else endocrine = 0; 
run;
* Create time lapse in months between assessments;
PROC SQL; 
	CREATE TABLE allwide1 AS select *,
	((B2DIYEAR*12 + B2DIMON)  - (aggyear*12 + aggmonth))  as lapseDS_AGG,
	((B2DIYEAR*12 + B2DIMON)  - (B4zcompy*12 + B4zcompm)) as lapseDS_BIO,
	((B4zcompy*12 + B4zcompm) - (aggyear*12 + aggmonth))  as lapseBIO_AGG
	FROM allwide; 
QUIT;
* Convert wide file to the first of two long files;
data all_long; set allwide1;
	array B2DCORWvar      [8] B2DCORW1-B2DCORW8;
	array B2DCORWTvar     [8] B2DCORWT1-B2DCORWT8;
	array pc_B2DCORWTvar  [8] pc_B2DCORWT1-pc_B2DCORWT8;
	array wpc_B2DCORWTvar [8] wpc_B2DCORWT1-wpc_B2DCORWT8;
	array time0var        [8] time0_1-time0_8; 
	array B2DCORAvar      [8] B2DCORA1-B2DCORA8;
	array B2DCORATvar     [8] B2DCORAT1-B2DCORAT8;
	array pc_B2DCORATvar  [8] pc_B2DCORAT1-pc_B2DCORAT8;
	array wpc_B2DCORATvar [8] wpc_B2DCORAT1-wpc_B2DCORAT8;
	array time1var        [8] time1_1-time1_8; 
	array B2DCORLvar      [8] B2DCORL1-B2DCORL8;
	array B2DCORLTvar     [8] B2DCORLT1-B2DCORLT8;
	array pc_B2DCORLTvar  [8] pc_B2DCORLT1-pc_B2DCORLT8;
	array wpc_B2DCORLTvar [8] wpc_B2DCORLT1-wpc_B2DCORLT8;
	array time2var        [8] time2_1-time2_8; 
	array B2DCORBvar      [8] B2DCORB1-B2DCORB8;
	array B2DCORBTvar     [8] B2DCORBT1-B2DCORBT8;
	array pc_B2DCORBTvar  [8] pc_B2DCORBT1-pc_B2DCORBT8;
	array wpc_B2DCORBTvar [8] wpc_B2DCORBT1-wpc_B2DCORBT8;
	array time3var        [8] time3_1-time3_8; 
	array dayvar          [8] B2DDAY1-B2DDAY8;
	array numstressvar[8]    stress1-stress8;
	array menstrualvar[8]    menstrual1-menstrual8;
	array bdrinkvar[8]       bdrink1-bdrink8;
	array wintervar[8]       winter1-winter8;
	array springvar[8]       spring1-spring8;
	array summervar[8]       summer1-summer8;
	array fallvar[8]         fall1-fall8;
	array negaffvar[8]       negaff1-negaff8;
	array medicationvar[8]   medication1-medication8;
	array medicationxvar[8]  medicationx1-medicationx8;
	array med1var[8]         b2dmed1_1-b2dmed1_8;
	array med2var[8]         b2dmed2_1-b2dmed2_8;
	array med3var[8]         b2dmed3_1-b2dmed3_8;
	array med4var[8]         b2dmed4_1-b2dmed4_8;
	array med5var[8]         b2dmed5_1-b2dmed5_8;
	array med6var[8]         b2dmed6_1-b2dmed6_8;
	array wkendvar[8]        wkend1-wkend8;

	do i = 1 to 8;
	B2DCORW = B2DCORWvar[i]; B2DCORWT = B2DCORWTvar[i]; pc_B2DCORWT = pc_B2DCORWTvar[i]; wpc_B2DCORWT = wpc_B2DCORWTvar[i]; time0 = time0var[i];
	B2DCORA = B2DCORAvar[i]; B2DCORAT = B2DCORATvar[i]; pc_B2DCORAT = pc_B2DCORATvar[i]; wpc_B2DCORAT = wpc_B2DCORATvar[i]; time1 = time1var[i];
	B2DCORL = B2DCORLvar[i]; B2DCORLT = B2DCORLTvar[i]; pc_B2DCORLT = pc_B2DCORLTvar[i]; wpc_B2DCORLT = wpc_B2DCORLTvar[i]; time2 = time2var[i];
	B2DCORB = B2DCORBvar[i]; B2DCORBT = B2DCORBTvar[i]; pc_B2DCORBT = pc_B2DCORBTvar[i]; wpc_B2DCORBT = wpc_B2DCORBTvar[i]; time3 = time3var[i];
	day = dayvar[i]; 
	numstress = numstressvar[i];
	menstruation = menstrualvar[i];
	med1 = med1var[i];
	med2 = med2var[i];
	med3 = med3var[i];
	med4 = med4var[i];
	med5 = med5var[i];
	med6 = med6var[i];
	wkend = wkendvar[i];
	medications = medicationvar[i];
	medicationsX = medicationxvar[i];
	bdrink = bdrinkvar[i];
	winterx = wintervar[i];
	springx = springvar[i];
	summerx = summervar[i];
	fallx = fallvar[i];
	dailynegaff = negaffvar[i];
	output; end;

	drop i 
	B2DCORA1-B2DCORA8 B2DCORAT1-B2DCORAT8 pc_B2DCORAT1-pc_B2DCORAT8 wpc_B2DCORAT1-wpc_B2DCORAT8
	B2DCORB1-B2DCORB8 B2DCORBT1-B2DCORBT8 pc_B2DCORBT1-pc_B2DCORBT8 wpc_B2DCORBT1-wpc_B2DCORBT8
	B2DCORL1-B2DCORL8 B2DCORLT1-B2DCORLT8 pc_B2DCORLT1-pc_B2DCORLT8 wpc_B2DCORLT1-wpc_B2DCORLT8
	B2DCORW1-B2DCORW8 B2DCORWT1-B2DCORWT8 pc_B2DCORWT1-pc_B2DCORWT8 wpc_B2DCORWT1-wpc_B2DCORWT8
	B2DDAY1-B2DDAY8 wkend1-wkend8 time0_1-time0_8 time1_1-time1_8 time2_1-time2_8 time3_1-time3_8 
	stress1-stress8 menstrual1-menstrual8 medication1-medication8
	bdrink1-bdrink8 winter1-winter8 spring1-spring8 summer1-summer8 fall1-fall8 negaff1-negaff8;

	if numstress = 8 then numstress = .;
run;

***********************
*** EXCLUSION CRITERIA;
**********************;

* Keep only samples where SAMPLMAJ = 1 or SAMPLMAJ = 4 or SAMPLMAJ = 13;
data all_long2; 
	set all_long; 
	where SAMPLMAJ = 1 or SAMPLMAJ = 4 or SAMPLMAJ = 13; 
run;
* Make cortisol measure and time of measure missing for entire day if wake time is earlier that 4:00 am or later than 11:00 am;
DATA all_long2; 
	SET all_long2;
	IF (B2DCORWT < 4) then do;   
	B2DCORW=.; B2DCORWT=.; B2DCORA=.; B2DCORAT=.; b2dcorL=.; B2DCORLT=.; b2dcorB=.; B2DCORBT=.; 
	end; 
	IF (B2DCORWT > 11) then do;  
	B2DCORW=.; B2DCORWT=.; B2DCORA=.; B2DCORAT=.; b2dcorL=.; B2DCORLT=.; b2dcorB=.; B2DCORBT=.; 
	end;
run;
* Make cortisol measure and time of measure missing for lunch and bedtime if either level increased by more than 10 nmol/L in comparison to the 30-min post-waking value;
DATA all_long2; 
	SET all_long2;
    IF ((B2DCORB - b2dcora) > 10) then do; 
	b2dcorB=.; B2DCORBT=.;
	end; 
	IF ((B2DCORL - b2dcora) > 10) then do; 
	b2dcorL=.; B2DCORLT=.; 
	end;
run;
* Make cortisol measure and time of measure missing for entire day if difference between B2DCORAT and B2DCORWT is less than .25 or greater than .75;
DATA all_long2; 
	SET all_long2;
	if ((B2DCORAT - B2DCORWT) <.25) then do; 
	B2DCORW=.; B2DCORWT=.; B2DCORA=.; B2DCORAT=.; b2dcorL=.; B2DCORLT=.; b2dcorB=.; B2DCORBT=.; 
	end; 
    if ((B2DCORAT - B2DCORWT) >.75) then do; 
	B2DCORW=.; B2DCORWT=.; B2DCORA=.; B2DCORAT=.; b2dcorL=.; B2DCORLT=.; b2dcorB=.; B2DCORBT=.; 
	end; 
run;
* Make cortisol measure and time of measure missing for bedtime if bedtime is later than midnight;
DATA all_long2; 
	SET all_long2;
    IF (B2DCORBT > 24) then do;  b2dcorB=.; B2DCORBT=.; 
	end;
run;

*******************************************
*** DATA WRANGLING POST-EXCLUSION CRITERIA;
******************************************;

* Calculate the average cortisol waking time by person and person centered cortisol time values;
PROC SQL; 
CREATE TABLE all_long1a AS select *,
mean(B2DCORWT) as pmeancortwaketime,
mean(numstress) as dailymeannumstressors
FROM all_long2
GROUP BY m2id; QUIT;
PROC SQL;
CREATE TABLE all_long1aa AS select *,
B2DCORWT - pmeancortwaketime as pmc_cortwt 
FROM all_long1a;
QUIT;
PROC SORT DATA = all_long1aa OUT = all_long1aa; 
	BY M2FAMNUM m2id; 
run;
* Convert to the final long file;
data all_long3; set all_long1aa;  
	array xCORTvar       	[4] B2DCORW     B2DCORA     B2DCORL     B2DCORB;
	array xCORTTIMEvar   	[4] B2DCORWT    B2DCORAT    B2DCORLT    B2DCORBT;
	array xpcCORTTIMEvar 	[4] pc_B2DCORWT pc_B2DCORAT pc_B2DCORLT pc_B2DCORBT;
	array xwpcCORTTIMEvar 	[4] wpc_B2DCORWT wpc_B2DCORAT wpc_B2DCORLT wpc_B2DCORBT;
	array cortday1var       [4] (0,0,0,0);
	array cortday2var       [4] (0,1,0,0);
	array cortday3var       [4] (0,0,1,0);
	array cortday4var       [4] (0,0,0,1);
	array indicator         [4] (1,2,3,4);

	do i = 1 to 4;
	t        = indicator[i];
	CORTx    = xCORTvar[i]; 
	logcortx = log(xCORTvar[i]+1); 
	CORTtime = xCORTTIMEvar[i]; 
	CORTpctime = xpcCORTTIMEvar[i]; 
	CORTwpctime = xwpcCORTTIMEvar[i]; 
	cortday1 = cortday1var[i];
	cortday2 = cortday2var[i];
	cortday3 = cortday3var[i];
	cortday4 = cortday4var[i];
	output; end;

	drop i B2DCORW B2DCORA B2DCORL B2DCORB B2DCORAT B2DCORLT B2DCORBT; 
run;
PROC SORT DATA = all_long3 OUT = all_long3; 
	BY M2FAMNUM m2id; 
run;
* Create ACE;
data all_long3;
	set all_long3;
	ACE = sum(sexabuse,welfare,peducation,pdivorce,pdeath,pemoabuse,pphyabuse);
run;

********************************************
*** MORE EXCLUSIONS POST-EXCLUSION CRITERIA;
*******************************************;

* Make cortisol measure missing if greater than 2000; 
data all_long3; 
	set all_long3; 
	if cortx > 20000 then do; 
	cortx=.; 
	end; 
run;
PROC SORT DATA = all_long3 OUT = all_long3; 
	BY M2FAMNUM m2id; 
run;
* The mean and sd of logcort with after all exclusion criteria are 2.2189627 and 0.9393778, respectively;  
* If outlier (mean + 3*sd = 5.0370961) then make log cortisol measure missing;
data all_long3; set all_long3;
if logcortx > 5.0370961 then logcort=.;
else if logcortx <= 5.0370961 then logcort=logcortx;
run;

**************************************
*** CREATE DATASET TO BE IMPUTED IN R;
*************************************;

* Create library;
libname lib "C:/Users/mcraft/Desktop/ACE and Cortisol/lib";
* Only keep useful variables for MI;
data lib.all_long4; 
	set all_long3 (keep = M2ID M2FAMNUM sexabuse racewhite Hispanic smoking 
	highschoolGED fouryrcollegeplus logincome fem B1PAGE_M2 medicationsx dailymeannumstressors 
	pmeancortwaketime welfare peducation pdivorce pdeath pemoabuse pphyabuse A1PDEPRE pmc_cortwt 
	numstress posaff negaff anxiety lifesat mhprofessional ownmeds dameds CORTpctime day t ACE
	logcortx cortx CORTtime CORTpctime m2_agg m1 daily);
run;
* Count number of individuals before applying exclusion criteria;
ods select nlevels;
proc freq data=lib.all_long4 nlevels;
   tables M2ID;
run; * 4490;

/* NEW IDEA: include all individuals from daily and impute ACE for those who may not have ACE;
* Only include people from daily who may have participated in MIDUS 1 and MIDUS 2;
data lib.all_long5; set lib.all_long4;
	where m2_agg = 1 and m1 = 1 and daily = 1;
	drop m2_agg m1 daily;
run;
ods select nlevels;
proc freq data=lib.all_long5 nlevels;
   tables M2ID;
run; * 1141;
*/

data lib.all_long5;
	set lib.all_long4;
run;
* Apply exclusion criteria;
proc sql; 
	delete from lib.all_long5 where cortx = . or logcortx = . or CORTtime = . OR CORTpctime=.; 
quit;
* Count number of individuals after applying exclusion criteria;
ods select nlevels;
proc freq data=lib.all_long5 nlevels;
   tables M2ID; 
run; * 1020;

******************************************************
*** CREATE ADDITIONAL VARIABLES NEEDED FOR IMPUTATION;
*****************************************************;

* Calculate standard deviation of all 16 measures for each individual;
PROC SORT DATA = lib.all_long5 OUT = lib.all_long6; 
	by M2ID; 
run;
proc means data=lib.all_long6 nway noprint; 
	by M2ID;
	var CORTx;
	output out=lib.sdCORT std=sdCORTx;  
run; 
proc sort data = lib.all_long6; 
	by M2ID; 
run;
proc sort data=lib.sdcort; 
	by M2ID;
run; 
data lib.all_long7;
	merge lib.all_long6 lib.sdcort;
	by M2ID;  
run; 
* Create mean of 4 morning, 4 peak, 4 lunch, and 4 bedtime cortisol measures for each individual;
PROC SORT DATA = lib.all_long7 OUT = lib.all_long8; 
	BY m2id t; 
run;
proc means data = lib.all_long8;
	by M2ID t;
	var CORTx; 
	output out = lib.means mean = meanCORTx;
run;
proc sort data = lib.all_long8; 
	by M2ID t; 
run;
proc sort data = lib.means; 
	by M2ID t; 
run;
data lib.all_long9; 
	merge lib.all_long8 lib.means; 
	by m2id t;
run;
proc sort data=lib.all_long9 out=lib.all_long9; 
	by M2FAMNUM m2id day; 
run;

***********************
*** EXPORT FOR MI IN R;
**********************;
