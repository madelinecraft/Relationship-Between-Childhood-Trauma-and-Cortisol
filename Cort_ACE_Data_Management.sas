* double click 29282-0001-Data to open;
* double click 04652-0001-Data to open;
* double click 02760-0001-Data to open;
* double click 26841-0001-Data to open;



* midus 2 biomarker project; 
* sexual abuse scale is B4QCT_SA;
*proc import datafile="U:\Documents\Projects\Mine\cortisol\29282-0001-Data.sav" out=midus2_biomrk dbms = sav replace; * run;
*proc cimport infile="C:\Documents\Projects\Mine\icpsrdata\29282-0001-Data.stc " lib=WORK; *run; 

data midus2_biomrk; set Da29282p1; 
keep M2FAMNUM m2id  SAMPLMAJ B4ZCOMPM B4ZCOMPY b4qma_d b4qma_a b4qcesd b4qta_ax b4qsa_sa B4O4B B4O5 B4O4A B4BCRP B4BFGN B4BSESEL B4BSICAM B4BIL6 B4QCT_SA; run; 
PROC SORT DATA = midus2_biomrk OUT = midus2_biomrk; BY M2FAMNUM m2id; run;
data midus2_biomrk; set midus2_biomrk;
if      B4QCT_SA >5 then sexabuse=1;
else if B4QCT_SA =5 then sexabuse = 0;
else if B4QCT_SA =. then sexabuse = .;
run;

* create a midus 2 biomarker project indicator;
data midus2_biomrk; set midus2_biomrk;
m2_biomrk = 1;
run;

*midus 2 aggregate project;
*background variables measured in the same longitudinal wave as daily cortisol meaures from the Daily Stress Project;
*proc import datafile= "U:\Documents\Projects\Mine\cortisol\04652-0001-Data.sav" out=midus2_agg dbms = sav replace; *run;
*proc cimport infile="U:\Documents\Projects\Mine\icpsrdata\04652-0001-Data.stc " lib=WORK; *run; 

data midus2_agg; set Da4652p1; 
keep  SAMPLMAJ M2FAMNUM m2id B1SBMI B1SA11G B1SA11x b1pf1 B1PB13 B1SNEGPA B1SBMI b1sa11g b1sa11x b1sa12b b1pb1 B1PA39 B1PIDATE 
     b1panxie b1pdepaf b1pa64 b1pa75 b1pa88H B1SPOSPA B1SNEGPA B1SPWBG2 B1SPWBS2 b1pb1 b1pf7a b1pf7b b1pf7c b1pf7d
     B1PB19 B1PBWORK B1STINC1; * marital status (B1PB19), employment status (B1PBWORK), and total household income (B1STINC1);
run; 

PROC SORT DATA = midus2_agg OUT = midus2_agg; BY M2FAMNUM m2id; run;

* define education by no high school/GED, HS/GED, or 4-year degree or higher;
data midus2_agg; set midus2_agg; education=b1pb1; race1 =  B1PF7A; race2 =  B1PF7B; run;
data midus2_agg; set midus2_agg; 
     if education = .                       then do; nohighschool = .; highschoolGED =.;  fouryrcollegeplus = .; end; 
else if education <=3                       then do; nohighschool = 1; highschoolGED = 0; fouryrcollegeplus  = 0; end;
else if (education >= 4 and education <= 8) then do; nohighschool = 0; highschoolGED = 1; fouryrcollegeplus  = 0; end;
else if education >= 9                      then do; nohighschool = 0; highschoolGED = 0; fouryrcollegeplus  = 1; end;
else if (education = 97 or education = 98)  then do; nohighschool = .; highschoolGED = .; fouryrcollegeplus  = .; end;
HSGEDplus = .;
if nohighschool = 1 then HSGEDplus = 0;
else if nohighschool = 0 then HSGEDplus = 1;

RaceWhite=.;
    if race1 = 1 and race2 = 9       then RaceWhite = 1; 
    else if race1 > 1 and race2 < 9  then RaceWhite = 0; 
    else if race1 = 7 or race1 = 8   then RaceWhite = .;

RaceBlack=.;
    if race1 = 2 or race2 = 2        then RaceBlack = 1; 
    else if race1 ^= 2 or race2 ^=2  then RaceBlack = 0; 
    else if race1 = 7 or race1 = 8   then RaceBlack = .;

RaceNotWhite=.;
    if RaceWhite=1 then RaceNotWhite = 0;
	else if RaceWhite=0 then RaceNotWhite = 1;

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

Logincome = log(Income);

run;

* create a midus 2 aggregate project indicator;
data midus2_agg; set midus2_agg;
m2_agg = 1;
run;

data midus2_agg; set midus2_agg; newdate = input(B1PIDATE,anydtdte32.); format newdate mmddyy10.; run;
data midus2_agg; set midus2_agg; aggday = day(newdate); aggmonth = month(newdate); aggyear = year(newdate); run;
PROC SORT DATA = midus2_agg OUT = midus2_agg; BY M2FAMNUM m2id; run;

*MIDUS 1 FOR ACE INDICATORS 1-6;
*proc import datafile="U:\Documents\Projects\Mine\cortisol\02760-0001-Data.sav" out=midus1 dbms = sav replace; *run;
*proc cimport infile="U:\Documents\Projects\Mine\icpsrdata\02760-0001-Data.stc " lib=WORK; *run; 
 
data midus1; set Da2760p1; 
keep SAMPLMAJ M2FAMNUM m2id A1PC14 A1PC8 A1PC2 A1PCA3 A1PCA1 A1PCA2 A1SE17A A1SE17B A1SE17F A1SE17G A1SE17K A1SE17L
A1PDEPRE A1SPOSAF A1SNEGAF A1PANXIE A1SSATIS A1SUSEMH A1SA40E A1PDEPRE A1SA10K;
run; 
PROC SORT DATA = midus1 OUT = midus1; BY M2FAMNUM m2id; run;

data midus1; set midus1;
posaff = A1SPOSAF;
	if A1SPOSAF = -1 then posaff = .;
	else if A1SPOSAF = 9 then posaff = .;
negaff = A1SNEGAF;
	if A1SNEGAF = -1 then negaff = .;
	else if A1SNEGAF = 9 then negaff = .;
anxiety = A1PANXIE;
	if A1PANXIE = -1 then anxiety = .;
	else if A1PANXIE = 9 then anxiety = .;
lifesat = A1SSATIS;
	if A1SSATIS = -1 then lifesat = .;
	else if A1SSATIS = 99 then lifesat = .;
mhprofessional = A1SUSEMH;
	if A1SUSEMH = -1 then mhprofessional = .;
	else if A1SUSEMH = 999 then mhprofessional = .;
ownmeds = .;
	if A1SA40E = 1 then ownmeds = 1;
	else if A1SA40E = 2 then ownmeds = 0;
	else if A1SA40E = . then ownmeds = .;
dameds = .;
	if A1SA10K = 1 then dameds = 1;
	else if A1SA10K = 2 then dameds = 0;
	else if A1SA10K = . then dameds = .;
run;

* create a midus 1 project indicator;
data midus1; set midus1;
m1 = 1;
run;

/*Indicators 1-6 from Midlife in the United States (MIDUS 1), 1995-1996 (ICPSR 2760)
(1) childhood financial status (i.e., family on welfare) = A1PC14
(2) parental education (i.e., less than 12 years); = either of these: A1PC8 (female) A1PC2 (male)
(3) parental divorce; = A1PCA3 
(4) parental death; = either of these: A1PCA1 (female) A1PCA2 (male)
(5) emotional abuse, = either of these: A1SE17A  (female) A1SE17B (male)
(6) physical abuse, = any of these: A1SE17F (female) A1SE17G (male) A1SE17K (severe, female) A1SE17L (severe, male) 
*/

DATA temp; 
  MERGE midus2_biomrk midus2_agg midus1; 
  BY M2FAMNUM m2id; 
RUN;

data temp; set temp;
welfare=.;
	if  A1PC14=1   then welfare=1; 
    else if A1PC14 = 2 then welfare=0;
    else if A1PC14 =.  then welfare=.; 
momeduc=.;
	if A1PC8 <=3                                  then momeduc=1; 
    else if A1PC8 >3 and A1PC8 <=12                   then momeduc=0;
    else if A1PC8  = 99                               then momeduc=0;
    else if A1PC8  = 97 or A1PC8  = 98                then momeduc=.;
dadeduc=.;
	if A1PC2 <=3                                  then dadeduc=1; 
    else if A1PC2 >3                                  then dadeduc=0;
    else if A1PC2  = 99                               then dadeduc=0;
    else if A1PC2  = 97 or A1PC2  = 98                then dadeduc=.;
peducation=.;
  	 if momeduc=1 or dadeduc=1 then peducation=1; 
    else if momeduc=0 and dadeduc=0 then peducation=0;
    else if momeduc=. and dadeduc=. then peducation=.;
pdivorce=.;
         if A1PCA3=1             then pdivorce=1;
    else if A1PCA3=2 or A1PCA3=9 then pdivorce=0;
    else if A1PCA3=7             then pdivorce=.;
momdeath=.;
	 if A1PCA1=1              then momdeath=1; 
    else if A1PCA1=2 or A1PCA1=9  then momdeath=0;
    else if A1PCA1=7              then momdeath=.;
daddeath=.;
	 if A1PCA2=1              then daddeath=1; 
    else if A1PCA2=2 or A1PCA2=9  then daddeath=0;
    else if A1PCA2=7              then daddeath=.;
pdeath=.;
	if momdeath=1 or daddeath=1  then pdeath=1; 
   else if momdeath=0 and daddeath=0 then pdeath=0;
   else if momdeath=. and daddeath=. then pdeath=.;
momemoabuse=.;
        if A1SE17A =1  or A1SE17A =2 or A1SE17A =3     then momemoabuse=1;
   else if A1SE17A =4  or A1SE17A =6                   then momemoabuse=0; 
   else if A1SE17A =-1 or A1SE17A =8                   then momemoabuse=.;
dademoabuse=.;
        if A1SE17B =1  or A1SE17B =2 or A1SE17B =3    then dademoabuse=1;
   else if A1SE17B =4  or A1SE17B =6                  then dademoabuse=0; 
   else if A1SE17B =-1 or A1SE17B =8                  then dademoabuse=.;
pemoabuse=.;
	if momemoabuse=1  or dademoabuse=1      then pemoabuse=1; 
   else if momemoabuse=0 and dademoabuse=0      then pemoabuse=0;
   else if momemoabuse=. and dademoabuse=.      then pemoabuse=.;
mompabuse=.;
        if A1SE17F=1  or A1SE17F=2 or A1SE17F=3  then mompabuse=1;
   else if A1SE17F=4  or A1SE17F=6               then mompabuse=0;
   else if A1SE17F=-1 or A1SE17F=8               then mompabuse=.;
momseverepabuse=.;
	if A1SE17K=1  or A1SE17K=2 or A1SE17K=3  then momseverepabuse=1;
   else	if A1SE17K=4  or A1SE17K=6               then momseverepabuse=0;
   else if A1SE17K=-1 or A1SE17K=8               then momseverepabuse=.;
momphyabuse=.;
	if mompabuse=0 and momseverepabuse=0     then momphyabuse=0;
   else if mompabuse=1 or  momseverepabuse=1     then momphyabuse=1;
   else if mompabuse=. and momseverepabuse=.     then momphyabuse=.;
dadpabuse=.;
        if A1SE17F=1  or A1SE17F=2 or A1SE17F=3  then dadpabuse=1;
   else if A1SE17F=4  or A1SE17F=6               then dadpabuse=0;
   else if A1SE17F=-1 or A1SE17F=8 		 then dadpabuse=.;
dadseverepabuse=.;
	if A1SE17K=1  or A1SE17K=2 or A1SE17K=3  then dadseverepabuse=1;
   else	if A1SE17K=4  or A1SE17K=6               then dadseverepabuse=0;
   else if A1SE17K=-1 or A1SE17K=8 		 then dadseverepabuse=.;
dadphyabuse=.;
	if dadpabuse=0 and dadseverepabuse=0     then dadphyabuse=0;
   else if dadpabuse=1 or  dadseverepabuse=1     then dadphyabuse=1;
   else if dadpabuse=. and dadseverepabuse=.     then dadphyabuse=.;
pphyabuse=.;
	if momphyabuse=1 or dadphyabuse=1       then pphyabuse=1; 
	else if momphyabuse=0 and dadphyabuse=0 then pphyabuse=0;
run;

/*/
* ACE scores based on sums even if an indicator is missing;
data temp; set temp; 
ACE_6=.; ACE_7=.;
ACE_6 = sum(         welfare, peducation, pdivorce, pdeath, pemoabuse, pphyabuse); 
ACE_7 = sum(sexabuse,welfare, peducation, pdivorce, pdeath, pemoabuse, pphyabuse); 
run;

* ACE scores only if all indicators are complete;
data temp; set temp; 
ACE_c6=.; 
if welfare >=0 and peducation >=0 and pdivorce >=0 and pdeath >=0 and pemoabuse >=0 and pphyabuse >=0 
then do ACE_c6 = sum(         welfare, peducation, pdivorce, pdeath, pemoabuse, pphyabuse); 
end;
run;

* ACE scores only if all indicators are complete;
data temp; set temp;
ACE_c7=.; 
if sexabuse >=0 and welfare >=0 and peducation >=0 and pdivorce >=0 and pdeath >=0 and pemoabuse >=0 and pphyabuse >=0
then do ACE_c7 = sum(sexabuse,welfare, peducation, pdivorce, pdeath, pemoabuse, pphyabuse); 
end;
run;

proc freq data=temp; table ACE_6 ACE_7 ACE_c6 ACE_c7; run;
/*/

*salivary cortisol measures; *2004-09 Daily stress project, multi-record formatted data set;
*proc import datafile="U:\Documents\Projects\Mine\cortisol\26841-0001-Data.sav" out=daily dbms = sav replace; *run; 
* proc cimport infile="U:\Documents\Projects\Mine\26841-0001-Data.stc " lib=WORK; *run; 

data daily; set Da26841p1; 
DATA daily; SET daily; 
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

*male binge (5+ drinks) and female binge (4+ drinks) the night before;
data daily1; set daily1;
    bingedrink =.;
	if      fem = 0 and B2DB3 >= 5 then bingedrink = 1; 
        else if fem = 0 and B2DB3 <5   then bingedrink = 0;
	else if fem = 1 and B2DB3 >= 4 then bingedrink = 1;
	else if fem = 1 and B2DB3 <4   then bingedrink = 0;
	else if             B2DB3 = .  then bingedrink = .;
	menstrual = .;
	if B2DB1T = 1 then menstrual = 1;
	else if B2DB1T ^= 1 then menstrual = 0;
	else if B2DB1T  = . then menstrual = .;
	winter=.; spring=.; summer=.; fall=.;
	if B2DIMON = 3 or B2DIMON = 4 or B2DIMON = 5 then spring = 1; else spring = 0; 
	if B2DIMON = 6 or B2DIMON = 7 or B2DIMON = 8 then summer = 1; else summer = 0;
	if B2DIMON = 9 or B2DIMON = 10 or B2DIMON = 11 then fall = 1; else fall = 0;
	if B2DIMON = 12 or B2DIMON = 1 or B2DIMON = 2 then winter = 1; else winter = 0;
        medications = .;
	if b2dmed1 = 1 or  b2dmed2 = 1 or b2dmed3 = 1 or b2dmed4 = 1 or b2dmed5 = 1 or b2dmed6 = 1 then medications = 1;
   	else medications = 0; * if missing, assume no such meds taken;
	medicationsx = .;
	if b2dmed2 = 1 or b2dmed3 = 1 or b2dmed4 = 1 or b2dmed5 = 1 or b2dmed6 = 1 then medicationsx = 1;
   	else medicationsx = 0; * if missing, assume no such meds taken;
run;

PROC SORT DATA = daily1 OUT = daily1; BY m2id; run;

data dailywide;  *convert daily stress project data file from long to wide;
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
keep SAMPLMAJ M2FAMNUM m2id SAMPLMAJ B2DIMON B2DIYEAR fem B1PAGE_M2
     wkend1-wkend8  stress1-stress8
     B2DCORWT1-B2DCORWT8 B2DCORAT1-B2DCORAT8 B2DCORLT1-B2DCORLT8 B2DCORBT1-B2DCORBT8
     B2DCORW1-B2DCORW8   B2DCORA1-B2DCORA8   B2DCORL1-B2DCORL8   B2DCORB1-B2DCORB8
     B2DDAY1-B2DDAY8     menstrual1-menstrual8 
     bdrink1-bdrink8 
     medication1-medication8 medicationx1-medicationx8 
     winter1-winter8 spring1-spring8 summer1-summer8 fall1-fall8
     negaff1-negaff8
     pc_B2DCORWT1-pc_B2DCORWT8 pc_B2DCORAT1-pc_B2DCORAT8 pc_B2DCORLT1-pc_B2DCORLT8 pc_B2DCORBT1-pc_B2DCORBT8
	 wpc_B2DCORWT1-wpc_B2DCORWT8 wpc_B2DCORAT1-wpc_B2DCORAT8 wpc_B2DCORLT1-wpc_B2DCORLT8 wpc_B2DCORBT1-wpc_B2DCORBT8
	 time0_1-time0_8 time1_1-time1_8 time2_1-time2_8 time3_1-time3_8
     B2DIMON B2DB1T B2DB3
b2dmed1_1-b2dmed1_8 b2dmed2_1-b2dmed2_8
b2dmed3_1-b2dmed3_8 b2dmed4_1-b2dmed4_8
b2dmed5_1-b2dmed5_8 b2dmed6_1-b2dmed6_8;
run;

PROC SORT DATA = dailywide OUT = dailywide; BY M2FAMNUM m2id; run;
data dailywide; set dailywide; if  SAMPLMAJ = 13 then M2FAMNUM = m2id; run;
PROC SORT DATA = temp OUT = temp; BY M2FAMNUM m2id; run;

* create a daily stress project indicator;
data dailywide; set dailywide;
daily = 1;
run;

data allwide; merge temp dailywide; by M2FAMNUM m2id; run;

* race/ethnicity

B1PF7A -  main racial origins   1=white
B1PF7B - same as above but allows for a second response to the question
B1PF7C - same as above but allows for a third response to the question;

data allwide; set allwide;
	endocrine = .;
	if      B4O4B = 1 or  B4O5 = 1 or  B4O4A = 1 or  B1SA11G = 1 or  B1SA11x = 1  then endocrine = 1;
	else if B4O4B = . and B4O5 = . and B4O4A = . and B1SA11G = . and B1SA11x = .  then endocrine = .;
	else endocrine = 0; 
run;

PROC SQL; *create time lapse in months between assessments;
CREATE TABLE allwide1 AS select *,
((B2DIYEAR*12 + B2DIMON)  - (aggyear*12 + aggmonth))  as lapseDS_AGG,
((B2DIYEAR*12 + B2DIMON)  - (B4zcompy*12 + B4zcompm)) as lapseDS_BIO,
((B4zcompy*12 + B4zcompm) - (aggyear*12 + aggmonth))  as lapseBIO_AGG
FROM allwide; 
QUIT;


*convert wide file to the first of two long files;
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

* all individuals have 8 records so file is still wide format in the
sense that the cortisol measures need to be fully stacked;
* on the above file, however, it's possible to fit the 'by wave' model;

* B1PDEPAF continuous depressed affect score
B1PANXIE anxiety continuous disorder score
B1SPOSPA Num 8 B1SPOSP.   Positive affect from PANAS (MIDUS2 new)
B1SNEGPA Num 8 B1SNEGP.   Negative affect from PANAS (MIDUS2 new)
B1SPWBG2 Num 8 B1SPWB3A.   Personal Growth (Psych Well-Being 7-item)
B1SPWBS2 Num 8 B1SPWB6A.   Self Acceptance (Psych Well-Being 7-item)

* A1SBMI body mass index;
* A1SA25 height in inches;
* A1SA27 weight in pounds;
* A1SA10A prescription for hypertension;
* A1SA10B prescription for diabetes;
* A1SA10C prescription for high cholesterol;
* A1SA10G prescription for arthritis;
* A1SA40E drugs used for depression;
* A1PDEPRE continuous depression code;

* our initial data point deletion rules;

*************************************************************************;
*** keep samples where SAMPLMAJ = 1 or SAMPLMAJ = 4 or SAMPLMAJ = 13;
*************************************************************************;
data all_long2; 
set all_long; 
where SAMPLMAJ = 1 or SAMPLMAJ = 4 or SAMPLMAJ = 13; 
run;


/** deletion rule 1;
DATA all_long1a;
SET all_long;
    IF ((B2DCORBT - B2DCORWT) < 12)  then do; b2dcorw=.; b2dcora=.; b2dcorL=.;  b2dcorB=.; end; *removes cortisol for entire day if awake less than 12 hours;
    IF ((B2DCORBT - B2DCORWT) > 20)  then do; b2dcorw=.; b2dcora=.; b2dcorL=.;  b2dcorB=.; end; *removes cortisol for entire day if awake more than 20 hours;
    IF (B2DCORWT <4 or B2DCORWT >11) then do; b2dcorw=.; b2dcora=.; b2dcorL=.;  b2dcorB=.; end; *removes cortisol for entire day if cortisol waking time before 4am or after 11 am;
    IF (B2DCORB - b2dcora) > 10      then do; b2dcorB=.; end; *removes cortisol for lunch and bedtime if either level increased by more than 10 nmol/L in comparison to the 30-min post-waking value;
    IF (B2DCORL - b2dcora) > 10      then do; b2dcorL=.; end;
run;
*/

DATA all_long2; SET all_long2;
	IF (B2DCORWT < 4) then do;   B2DCORW=.; B2DCORWT=.; B2DCORA=.; B2DCORAT=.; b2dcorL=.; B2DCORLT=.; b2dcorB=.; B2DCORBT=.; end; 
	*removes cortisol for entire day if cortisol waking time before 4am or after 11 am;
run;
DATA all_long2; SET all_long2;
    IF (B2DCORWT > 11) then do;  B2DCORW=.; B2DCORWT=.; B2DCORA=.; B2DCORAT=.; b2dcorL=.; B2DCORLT=.; b2dcorB=.; B2DCORBT=.; end;
run;
DATA all_long2; SET all_long2;
    IF ((B2DCORB - b2dcora) > 10) then do; b2dcorB=.; B2DCORBT=.; end; *removes cortisol for lunch and bedtime if either level increased by more than 10 nmol/L in comparison to the 30-min post-waking value;
run;
DATA all_long2; SET all_long2;
    IF ((B2DCORL - b2dcora) > 10) then do; b2dcorL=.; B2DCORLT=.; end;
run;
/*DATA all_long1; SET all_long1; IF ((B2DCORWT - waketime) >.25) then do; B2DCORW=.; B2DCORWT=.; B2DCORA=.; B2DCORAT=.; end; run;
DATA all_long1; SET all_long1; IF ((B2DCORWT - WakeTime) < 0)  then do; B2DCORW=.; B2DCORWT=.; B2DCORA=.; B2DCORAT=.; end; run;
*/
DATA all_long2; SET all_long2;
    if ((B2DCORAT - B2DCORWT) <.25) then do; B2DCORW=.; B2DCORWT=.; B2DCORA=.; B2DCORAT=.; b2dcorL=.; B2DCORLT=.; b2dcorB=.; B2DCORBT=.; end; 
run;
DATA all_long2; SET all_long2;
   if ((B2DCORAT - B2DCORWT) >.75) then do; B2DCORW=.; B2DCORWT=.; B2DCORA=.; B2DCORAT=.; b2dcorL=.; B2DCORLT=.; b2dcorB=.; B2DCORBT=.; end; 
run;
DATA all_long2; SET all_long2;
    IF (B2DCORBT > 24) then do;  b2dcorB=.; B2DCORBT=.; end;
run;

PROC SQL; *calculate the average cortisol waking time by person and person centered cortisol time values;
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

PROC SORT DATA = all_long1aa OUT = all_long1aa; BY M2FAMNUM m2id; run;


*convert to the final long file;
data all_long3; set all_long1aa;  
array xCORTvar       [4] B2DCORW     B2DCORA     B2DCORL     B2DCORB;
array xCORTTIMEvar   [4] B2DCORWT    B2DCORAT    B2DCORLT    B2DCORBT;
array xpcCORTTIMEvar [4] pc_B2DCORWT pc_B2DCORAT pc_B2DCORLT pc_B2DCORBT;
array xwpcCORTTIMEvar [4] wpc_B2DCORWT wpc_B2DCORAT wpc_B2DCORLT wpc_B2DCORBT;
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
drop i  B2DCORW B2DCORA B2DCORL B2DCORB B2DCORAT B2DCORLT B2DCORBT ;  *pc_corwt pc_corat pc_corlt pc_corbt ;
run;

PROC SORT DATA = all_long3 OUT = all_long3; BY M2FAMNUM m2id; run;

data all_long3; set all_long3; if cortx >20000 then do; cortx=.; end; run;

PROC SORT DATA = all_long3 OUT = all_long3; BY M2FAMNUM m2id; run;

* mean logcort with exclusion criteria above: mean = 2.2189627 sd = 0.9393778  
out cut point for outliers is mean + 3*sd = 5.0370961;
data all_long3; set all_long3;
if logcortx > 5.0370961 then logcort=.;
else if logcortx <= 5.0370961 then logcort=logcortx;
run;

************FOR MI*************;

libname lib "C:/Users/mcraft/Desktop/ACE and Cortisol/lib";

* only keep variables I'm interested in for MI;
data lib.all_long4; set all_long3 (keep = M2ID M2FAMNUM sexabuse racewhite Hispanic smoking highschoolGED 
fouryrcollegeplus logincome fem B1PAGE_M2 medicationsx dailymeannumstressors pmeancortwaketime 
welfare peducation pdivorce pdeath pemoabuse pphyabuse A1PDEPRE pmc_cortwt numstress
posaff negaff anxiety lifesat mhprofessional ownmeds dameds CORTpctime day t
logcortx cortx CORTtime CORTpctime m2_agg m1 daily);
run;

ods select nlevels;
proc freq data=lib.all_long4 nlevels;
   tables M2ID;
run; * 4490;

* only include people from daily who may have participated in MIDUS 1 and MIDUS 2;
data lib.all_long5; set lib.all_long4;
where m2_agg = 1 and m1 = 1 and daily = 1;
drop m2_agg m1 daily;
run;

ods select nlevels;
proc freq data=lib.all_long5 nlevels;
   tables M2ID;
run; * 1141;

proc sql; delete from lib.all_long5 where cortx = . or logcortx = . or CORTtime = . OR CORTpctime=.; quit;

ods select nlevels;
proc freq data=lib.all_long5 nlevels;
   tables M2ID; 
run; * 926;

* instead of deleting, make all important variables missing;
/*/
data lib.all_long6; set lib.all_long5;
if (cortx = . or logcortx = . or CORTtime = . OR CORTpctime=.) then do;
sexabuse=.; racewhite=.; Hispanic=.; smoking=.; highschoolGED=.; fouryrcollegeplus=.; logincome=.; fem=.; 
B1PAGE_M2=.; medicationsx=.; dailymeannumstressors=.; pmeancortwaketime=.; welfare=.; peducation=.; 
pdivorce=.; pdeath=.; pemoabuse=.; pphyabuse=.; A1PDEPRE=.; pmc_cortwt=.; numstress=.; posaff=.; negaff=.; 
anxiety=.; lifesat=.; mhprofessional=.; ownmeds=.; dameds=.; CORTpctime=.; day=.; t=.; logcortx=.; cortx=.; CORTtime=.;
end; 
run;
/*/

* create sd of all 16 measures for an ID;
PROC SORT DATA = lib.all_long5 OUT = lib.all_long6; by M2ID; run;
proc means data=lib.all_long6 nway noprint; 
by M2ID;
class M2ID; 
var CORTx;
output out=lib.sdCORT 
std=sdCORTx;  
run; 

proc sort data = lib.all_long6; by M2ID; run;
proc sort data=lib.sdcort; by M2ID; run; 

data lib.all_long7;
merge lib.all_long6 lib.sdcort;
by M2ID;  
run; 

* create average morning, peak, lunch, and bedtime cortisol measures across four days;
PROC SORT DATA = lib.all_long7 OUT = lib.all_long8; BY m2id t; run;

proc means data = lib.all_long8;
by M2ID t;
var CORTx; 
output out = lib.means mean = meanCORTx;
run;

proc sort data = lib.all_long8; by M2ID t; run;
proc sort data = lib.means; by M2ID t; run;

data lib.all_long9; 
merge lib.all_long8 lib.means; 
by m2id t;
run;
 
proc sort data=lib.all_long9 out=lib.all_long9; by M2FAMNUM m2id day; run;


* transposing doesn't work if I delete;
/*/
proc sort data=lib.all_long10 out=lib.all_long10; by M2FAMNUM m2id day; run;

* transpose long to wide (first of two);
data lib.wide10;  
 array meanCORTxvar[4]    meanCORTx1-meanCORTx4;
 array CORTpctimevar[4]   CORTpctime1-CORTpctime4;
 array logcortxvar[4]     logcortx1-logcortx4;
 array tvar[4]     		  t1-t4;

 do i = 1 to 4 until (last.m2id); set lib.all_long10; by m2id;   

meanCORTxvar [i] =   	  meanCORTx;
CORTpctimevar [i] =       CORTpctime;
logcortxvar [i] =         logcortx;
tvar [i] =                t;
end;

keep M2ID M2FAMNUM sexabuse racewhite Hispanic smoking highschoolGED 
fouryrcollegeplus logincome fem B1PAGE_M2 medicationsx dailymeannumstressors pmeancortwaketime 
sdCORTx welfare peducation pdivorce pdeath pemoabuse pphyabuse A1PDEPRE pmc_cortwt numstress
posaff negaff anxiety lifesat mhprofessional ownmeds dameds day logcortx1-logcortx4 
CORTpctime1-CORTpctime4 meanCORTx1-meanCORTx4 t1-t4;
run;
/*/

/*/
* transpose long to wide (second of two);
data wide9;  
 array pmc_cortwtvar[8]     pmc_cortwt1-pmc_cortwt8;
 array numstressvar[8]      numstress1-numstress8;
 array dayvar[8]            day1-day8;

 array logcortx1var[8]      logcortx1-logcortx8;
 array logcortx2var[8]      logcortx9-logcortx16;
 array logcortx3var[8]      logcortx17-logcortx24;
 array logcortx4var[8]      logcortx25-logcortx32;

 array CORTpctime1var[8]    CORTpctime1-CORTpctime8;
 array CORTpctime2var[8]    CORTpctime9-CORTpctime16;
 array CORTpctime3var[8]    CORTpctime17-CORTpctime24;
 array CORTpctime4var[8]    CORTpctime25-CORTpctime32;

 array t1var[8]             t1-t8;
 array t2var[8]             t9-t16;
 array t3var[8]             t17-t24;
 array t4var[8]             t25-t32;

 do i = 1 to 8 until (last.m2id); set wide8; by m2id;   

pmc_cortwtvar [i] =   	  pmc_cortwt;
numstressvar [i] =        numstress;
dayvar [i] =              day;

logcortx1var [i] =        logcortx1;
logcortx2var [i] =        logcortx2;
logcortx3var [i] =        logcortx3;
logcortx4var [i] =        logcortx4;

CORTpctime1var [i] =      CORTpctime1;
CORTpctime2var [i] =      CORTpctime2;
CORTpctime3var [i] =      CORTpctime3;
CORTpctime4var [i] =      CORTpctime4;

t1var [i] =               t1;
t2var [i] =               t2;
t3var [i] =               t3;
t4var [i] =               t4; 

end;

keep M2ID sexabuse racewhite Hispanic smoking highschoolGED 
fouryrcollegeplus logincome fem B1PAGE_M2 medicationsx dailymeannumstressors pmeancortwaketime 
sdCORTx welfare peducation pdivorce pdeath pemoabuse pphyabuse A1PDEPRE pmc_cortwt1-pmc_cortwt8 numstress1-numstress8
posaff negaff anxiety lifesat mhprofessional ownmeds dameds day1-day8 logcortx1-logcortx8 logcortx9-logcortx16 
logcortx17-logcortx24 logcortx25-logcortx32 
CORTpctime1-CORTpctime8 CORTpctime9-CORTpctime16 CORTpctime17-CORTpctime24 CORTpctime25-CORTpctime32 
meanCORTx1-meanCORTx4 t1-t8 t9-t16 t17-t24 t25-t32;
run;
/*/


























data descriptives; set all_long2; 
keep m2id Hispanic B1PF1 nohighschool highschoolGED fouryrcollegeplus HSGEDplus 
     smoking RaceWhite RaceBlack RaceNotWhite fem B1PAGE_M2 pmeancortwaketime 
     sexabuse welfare peducation pdivorce pdeath pemoabuse pphyabuse ACE_6 ACE_7 ACE_c6 ACE_c7  
     B1PB19 B1PBWORK B1STINC1 dailymeannumstressors smoking medicationsx; 
run;
proc sort data=descriptives nodup out=ex1;
 by m2id;
 run; 

proc freq data=ex1; 
where B1PAGE_M2>0 and dailymeannumstressors>=0 and smoking>=0 and medicationsx >=0 and fem>=0;
table B1PB19 B1PBWORK Hispanic nohighschool highschoolGED fouryrcollegeplus HSGEDplus smoking fem medicationsx racewhite raceblack racenotwhite
      sexabuse welfare peducation pdivorce pdeath pemoabuse pphyabuse ACE_6 ACE_7 ACE_c6 ACE_c7  ;
run;

* evaluate patterns of missing data;
proc mi data = ex1 nimpute=0;
var sexabuse welfare peducation pdivorce pdeath pemoabuse pphyabuse 
    fem RaceBlack RaceWhite racenotwhite Hispanic smoking B1PAGE_M2 pmeancortwaketime 
	nohighschool highschoolGED fouryrcollegeplus HSGEDplus dailymeannumstressors;
run;

proc freq data=ex1; table  ACE_6 ACE_7 ACE_c6 ACE_c7; run;

proc corr data=ex1; 
where B1PAGE_M2>0 and ace_c6>=0 and dailymeannumstressors>=0 and HSGEDplus>=0 and racenotwhite>=0;
var welfare peducation pdivorce pdeath pemoabuse pphyabuse ; run;

proc corr data=ex1; 
where B1PAGE_M2>0 and ace_c7>=0 and dailymeannumstressors>=0 and HSGEDplus>=0 and racenotwhite>=0;
var sexabuse welfare peducation pdivorce pdeath pemoabuse pphyabuse ; run;

proc means data=ex1 mean std min max n; 
where B1PAGE_M2>0 and dailymeannumstressors>=0 and smoking>=0 and medicationsx >=0 and fem>=0;
var pmeancortwaketime B1PAGE_M2 fem nohighschool highschoolGED fouryrcollegeplus raceblack racewhite hispanic racenotwhite dailymeannumstressors; 
run; 

