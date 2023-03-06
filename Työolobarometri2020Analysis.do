* 14.02.2023
* Elisabet Miheludaki
* Työolobarometri 2020 dataset analysis

* Research question: Is wellbeing associated with the sex, part-time / full-time status, or type of employment contract of workers(permanent/fixed term)?
* The number of days that workers took sick leave in the past year is used as a proxy for wellbeing assuming that the wellbeing of workers who took less sick leave will have been higher.

clear
set more off
capture log close

cd "C:\Users\lizou\Dropbox\Empower Everyone\PHD\2023\ARP\FSD3645_Työolobarometri2020\FSD3645\Study\Data"

log using "C:\Users\lizou\Dropbox\Empower Everyone\PHD\2023\ARP\FSD3645_Työolobarometri2020\FSD3645\Study\Data\log for 14.02.2023.smcl", replace

use "C:\Users\lizou\Dropbox\Empower Everyone\PHD\2023\ARP\FSD3645_Työolobarometri2020\FSD3645\Study\Data\CleanedData_Tyolobarometri.dta"

* Exploring variable sukup "Sex"
* binary variable with no missing observations
* renaming it to something more descriptive 
ta sukup, m
rename sukup sex

* Exploring variable tysuhpy "Contract Type"
* renaming it to something more descriptive 
* dropping 78 values that are missing
* the variable has 2 levels, permanent and fixed-term
ta tysuhpy, m
rename tysuhpy workcontract
drop if workcontract==3 
drop if workcontract==.
ta workcontract, m

* Exploring variable taikao "Work Time"
* renaming it to something more descriptive 
* dropping 72 values that are missing
* the variable has 2 levels, part-time and full-time work
ta taikao, m
rename taikao worktime
drop if worktime==.
ta worktime, m

* Exploring variable k32 "Sick Leave"
* no missing variables
* renaming it to something more descriptive
* dropping two observations (999) that are misreported - a year only has 365 days, so a respondent cannot report that they have been sick for 999 days during the past year
* visualizing the data in a histogram - 597 out of 1567 observations take the value of 0 making the visualization not so informative
ta k32, m
rename k32 sickleavedays
drop if sickleavedays==999
ta sickleavedays, m
histogram sickleavedays

* Categories could be created for the sick leave variable observations for example 0 for no sick leave days, 1 for 1-5 days, 2 for 6-10 days, 3 for 11-20 days, 4 for 21-40 days, 5 for 41-80 days, 6 for 81-150 (148 was the highest number of days reported) The categories are smaller for lower numbers of sick leave days reported as that is where most of the respondents are distributed, and become gradually larger as fewer people report higher sick leave days. For example cat 1 has only 3 days but 23.68 % of respondents vs cat 6 that has 70 days but only 0.96 % of respondents.
generate sickleavedaycats=.
replace sickleavedaycats=0 if sickleavedays==0
replace sickleavedaycats=1 if sickleavedays>=1 & sickleavedays<=5
replace sickleavedaycats=2 if sickleavedays>=6 & sickleavedays<=11
replace sickleavedaycats=3 if sickleavedays>=12 & sickleavedays<=25
replace sickleavedaycats=4 if sickleavedays>=26 & sickleavedays<=40
replace sickleavedaycats=5 if sickleavedays>=41 & sickleavedays<=80
replace sickleavedaycats=6 if sickleavedays>=81 & sickleavedays<=150

label define sickleavedaycatscat 0 "0" 1 "1-5" 2 "6-11" 3 "12-25" 4 "26-40" 5 "41-80" 6 "81-150"

label val sickleavedaycats agecat
label var sickleavedaycats "Sick Leave Day Categories"

ta sickleavedaycats
histogram sickleavedaycats

* Summarizing the cleaned data - we end up with 1567 observations for the analysis
summ

* Data analysis
* Linear regression will be utilized to predict the dependent continuous variable sickleavedays (as a proxy of wellbeing)

regress sickleavedays worktime sex workcontract 
estimates store m1, title(Model 1)

regress sickleavedays sex workcontract 
estimates store m2, title(Model 2)

regress sickleavedays worktime sex 
estimates store m3, title(Model 3)

* Create table with regression results
estout m1 m2 m3, cells(b(star fmt(3)) se(par fmt(2))) legend label varlabels(_cons Constant) stats(r2 bic, fmt(3 0 1) label(R-sqr BIC))

cd "C:\Users\lizou\Dropbox\Empower Everyone\PHD\2023\ARP\FSD3645_Työolobarometri2020\FSD3645\Study\Data"

* Measurement errors
* Model 1
regress sickleavedays worktime sex workcontract
predict model1_residual, resid
sum model1_resid, detail
estimates store m1, title(Model 1)
browse if model1_residual>14 | model1_residual<-7

* Model 2
regress sickleavedays sex workcontract
predict model2_residual, resid
sum model2_resid, detail
estimates store m2, title(Model 2)
browse if model2_residual>14 | model2_residual<-7

* Model 3
regress sickleavedays worktime sex
predict model3_residual, resid
sum model3_resid, detail
estimates store m3, title(Model 3)
browse if model3_residual>14 | model3_residual<-7

* Measurement errors using Cooks D
* Model 1
regress sickleavedays worktime sex workcontract
predict model1_CooksD, cooksd
browse if model1_CooksD>1

* Model 2
regress sickleavedays sex workcontract
predict model2_CooksD, cooksd
browse if model2_CooksD>1

* Model 3
regress sickleavedays worktime sex
predict model3_CooksD, cooksd
browse if model3_CooksD>1

* Heteroskedasticity
estat hettest
regress sickleavedays worktime sex workcontract

estat hettest
regress sickleavedays sex workcontract

estat hettest
regress sickleavedays worktime sex

* Specification errors
estat ovtest
estat ovtest, rhs

regress sickleavedays worktime sex workcontract, vce(robust)
estat ic

regress sickleavedays sex workcontract, vce(robust)
estat ic

regress sickleavedays worktime sex, vce(robust)
estat ic

* Multicollinearity
pwcorr sickleavedays worktime sex workcontract
estat vif

pwcorr sickleavedays sex workcontract
estat vif

pwcorr sickleavedays worktime sex
estat vif

* to look for outlier variables:
regress sickleavedays worktime sex workcontract
predict p
predict stdres, rstand
scatter stdres p, yline(0)
gen id=_n
scatter stdres id, yline(0) mlab(id)

* better model if we drop outliers?
clist if  id==114 | id==145 | id==218 | id==293 | id==319 | id==597 | id==646 | id==835 | id==852 | id==888 | id==1240

drop if id==114 | id==145 | id==218 | id==293 | id==319 | id==597 | id==646 | id==835 | id==852 | id==888 | id==1240

regress sickleavedays worktime sex workcontract, vce(robust)
estat ic

* Create table with final regression results
regress sickleavedays worktime sex workcontract, vce(robust)
estimates store m4, title(Model 4)

estout m4, cells(b(star fmt(3)) se(par fmt(2))) legend label varlabels(_cons Constant) stats(r2 bic, fmt(3 0 1) label(R-sqr BIC))

* Visualization
coefplot, xline(0)
coefplot m1 m2 m3, xline(0) drop(_cons) keep (sickleavedays worktime sex workcontract)
coefplot m1, xline(0) drop(_cons) keep (sickleavedays worktime sex workcontract)



* Class notes:
*logit line at 0
*logistic line at 1