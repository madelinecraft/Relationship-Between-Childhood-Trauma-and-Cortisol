libname out1 "/home/users/mcraft.AD3/CortACEProject/output1";
*libname out1 "C:/Users/mcraft/Desktop/ACE and Cortisol/out1";

proc import datafile="/home/users/mcraft.AD3/CortACEProject/mi_data1.txt" out=out1.data dbms = dlm replace; run;
*proc import datafile = "C:/Users/mcraft/Desktop/ACE and Cortisol/mi_data1.txt" out=out1.data dbms = dlm replace; *run;

* sort data;
proc sort data = out1.data; by imp M2ID M2FAMNUM day; run;

* rename imp;
data out1.data; set out1.data;
_imputation_ = imp;
run;

* fit the model by imputation;
title1 'linear-exponential continuous time with between-person heterogeneity of the residual variance at level 1'; 
proc nlmixed data=out1.data gconv=0 qpoints=30 noad cov; 
parms
tau0	-1.8374
tau1	-0.00984
tau2	0.001102
tau12	0.0068
tau3a	-0.0017
tau3b	0.08458
tau4a	-0.00456
tau4b	0.01064
tau5	0.2525
tau6	0.04345
tau7	0.03332
f00	3.0796
f01	0.02368
f02	0.008612
f012	-0.00753
f03a	-0.00932
f03b	-0.03263
f04a	-0.09188
f04b	-0.01111
f05	-0.1124
f06	-0.06386
f07	-0.04289
f10	0.4911
f11	0.1215
f12	0.01135
f112	-0.01251
f13a	-0.00637
f13b	0.03467
f14a	-0.161
f14b	-0.01282
f15	0.1718
f16	0.009191
f17	0.01204
f20	0.7425
f21	-0.0261
f22	0.01779
f212	-0.00645
f23a	-0.00937
f23b	0.01822
f24a	0.05875
f24b	0.07492
f25	0.1352
f26	0.05685
f27	0.04211
f30	0.1079
f31	0.00969
f32	0.000432
f312	-0.00024
f33a	-0.00224
f33b	0.001371
f34a	0.01524
f34b	0.01485
f35	-0.0109
f36	0.003609
f37	0.005133
alp00	-1.8084
alp01	-0.2442
alp02	-0.01057
alp012	0.03116
alp03a	0.0453
alp03b	0.06707
alp04a	-0.138
alp04b	-0.04473
alp05	0.2652
alp06	0.3553
alp07	0.09273
alp10	-2.0734
alp11	0.1211
alp12	0.01544
alp112	-0.04072
alp13a	0.09832
alp13b	-0.1135
alp14a	-0.9139
alp14b	-0.3974
alp15	-0.08615
alp16	-0.313
alp17	0.03604
rho10	0.2677
alp20	-1.5336
alp21	-0.09595
alp22	0.00442
alp212	0.01045
alp23a	-0.01165
alp23b	0.05023
alp24a	0.007899
alp24b	-0.09071
alp25	0.4036
alp26	0.2664
alp27	-0.05586
rho20	0.1762
rho21	-0.1798
rhov0	0.03675
rhov1	0.05709
rhov2	0.5534
alpv	-0.9544;

by _imputation_;
where _imputation_ = 1;

sdu0 =sqrt(exp(alp00 + alp01*fem + alp02*agec + alp012*fem*agec + alp03a*dstressc + alp03b*mstress + alp04a*pmc_cortwt + alp04b*mwake + alp05*smoking + alp06*medicationsx + alp07*ace));
sdu1 =sqrt(exp(alp10 + alp11*fem + alp12*agec + alp112*fem*agec + alp13a*dstressc + alp13b*mstress + alp14a*pmc_cortwt + alp14b*mwake + alp15*smoking + alp16*medicationsx + alp17*ace));
sdu2 =sqrt(exp(alp20 + alp21*fem + alp22*agec + alp212*fem*agec + alp23a*dstressc + alp23b*mstress + alp24a*pmc_cortwt + alp24b*mwake + alp25*smoking + alp26*medicationsx + alp27*ace));
sdv  =sqrt(exp(alpv));

s2e = exp(tau0 + tau1*fem + tau2*agec + tau12*fem*agec + tau3a*dstressc + tau3b*mstress + tau4a*pmc_cortwt + tau4b*mwake + tau5*smoking + tau6*medicationsx + tau7*ace + theta3*sdv); 
a0  = f00 + f01*fem + f02*agec + f012*fem*agec + f03a*dstressc + f03b*mstress + f04a*pmc_cortwt + f04b*mwake + f05*smoking + f06*medicationsx + f07*ace + theta0*sdu0; 
a1  = f10 + f11*fem + f12*agec + f112*fem*agec + f13a*dstressc + f13b*mstress + f14a*pmc_cortwt + f14b*mwake + f15*smoking + f16*medicationsx + f17*ace + theta1*sdu1; 
b1  = f20 + f21*fem + f22*agec + f212*fem*agec + f23a*dstressc + f23b*mstress + f24a*pmc_cortwt + f24b*mwake + f25*smoking + f26*medicationsx + f27*ace + theta2*sdu2;
b2  = f30 + f31*fem + f32*agec + f312*fem*agec + f33a*dstressc + f33b*mstress + f34a*pmc_cortwt + f34b*mwake + f35*smoking + f36*medicationsx + f37*ace;
knot = 0;
if (CORTpctime <= knot) then predv = a0 + a1*CORTpctime;
if (CORTpctime > knot)  then predv =  b1 - (b1 - ((a0 - b1 + b1)))*exp(-b2*CORTpctime) ;
model logcortx ~ normal(predv,s2e);
random theta0 theta1 theta2 theta3 ~ normal([0,0,0,0],[1,
                                                       rho10,1,
                                                       rho20,rho21,1,
                                                       rhov0,rhov1,rhov2,1]) subject= m2id;
ods output ParameterEstimates = out1.myparamest CovMatParmEst = out1.mycovmat;
run;
