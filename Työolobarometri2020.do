* 31.01.2023
* Elisabet Miheludaki
* Työolobarometri 2020 dataset cleaning
* Research question: Is wellbeing associated with the sex, part-time / full-time status, or type of employment contract of workers(permanent/fixed term)?
* The number of days that workers took sick leave in the past year is used as a proxy for wellbeing assuming that the wellbeing of workers who took less sick leave will have been higher.

* dataset selection
clear
set more off
capture log close

set maxvar 10000

cd "C:\Users\lizou\Dropbox\Empower Everyone\PHD\2023\ARP\FSD3645_Työolobarometri2020\FSD3645\Study\Data"

log using "C:\Users\lizou\Dropbox\Empower Everyone\PHD\2023\ARP\FSD3645_Työolobarometri2020\FSD3645\Study\Data\log for 31.01.2023.smcl", replace

use "C:\Users\lizou\Dropbox\Empower Everyone\PHD\2023\ARP\FSD3645_Työolobarometri2020\FSD3645\Study\Data\CleanedData_Tyolobarometri.dta"

* data selection - there are 5 variables and 1647 observations in the selected dataset
keep fsd_id sukup tysuhpy taikao k32

codebook
describe

ssc install mdesc
mdesc

summ

* exploring variable sukup "Sex"
* binary variable with no missing observations
* renaming it to something more descriptive 
ta sukup, m
rename sukup sex

* exploring variable tysuhpy "Contract Type"
* renaming it to something more descriptive 
* dropping 78 values that are missing
* the variable has 2 levels, permanent and fixed-term
ta tysuhpy, m
rename tysuhpy workcontract
drop if workcontract==3 
drop if workcontract==.
ta workcontract, m

* exploring variable taikao "Work Time"
* renaming it to something more descriptive 
* dropping 72 values that are missing
* the variable has 2 levels, part-time and full-time work
ta taikao, m
rename taikao worktime
drop if worktime==.
ta worktime, m

* exploring variable k32 "Sick Leave"
* no missing variables
* renaming it to something more descriptive
* dropping two observations (999) that are misreported - a year only has 365 days, so a respondent cannot report that they have been sick for 999 days during the past year
* visualizing the data in a histogram - 597 out of 1567 observations take the value of 0 making the visualization not so informative
ta k32, m
rename k32 sickleavedays
drop if sickleavedays==999
ta sickleavedays, m
histogram sickleavedays

* categories could be created for the sick leave variable observations for example 0 for no sick leave days, 1 for 1-3 days, 2 for 4-10 days, 3 for 11-20 days, 4 for 21-40 days, 5 for 41-80 days, 6 for 81-150
generate sickleavedaycats=.
replace sickleavedaycats=0 if sickleavedays==0
replace sickleavedaycats=1 if sickleavedays>=1 & sickleavedays<=3
replace sickleavedaycats=2 if sickleavedays>=4 & sickleavedays<=10
replace sickleavedaycats=3 if sickleavedays>=11 & sickleavedays<=20
replace sickleavedaycats=4 if sickleavedays>=21 & sickleavedays<=40
replace sickleavedaycats=5 if sickleavedays>=41 & sickleavedays<=80
replace sickleavedaycats=6 if sickleavedays>=81 & sickleavedays<=150

label define sickleavedaycatscat 0 "0" 1 "1-3" 2 "4-10" 3 "11-20" 4 "21-40" 5 "41-80" 6 "81-150"

label val sickleavedaycats agecat
label var sickleavedaycats "Sick Leave Day Categories"

ta sickleavedaycats
histogram sickleavedaycats

* summarizing the cleaned data - we end up with 1567 observations for the analysis
summ

* examining multiple variables at a time by cross-tabbing them
ta sex sickleavedaycats, m
ta workcontract sickleavedaycats, m
ta worktime sickleavedaycats, m




