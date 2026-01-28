/*****************************************************************************************************************
Program:      run_crossover.sas
Purpose:      Implementation of relative bioavailability analysis for a 2x2 crossover design using PROC MIXED.
              Comparison of fixed-effects vs. mixed-effects approaches with both balanced and unbalanced datasets.
Author:       Bianca Gasparini
Input:        - &root/sim_data.csv (balanced 2x2 crossover dataset)
              - &root/sim_data_un.csv (unbalanced 2x2 crossover dataset)
Output:       - results.table_[model]_[dataset] 
              - Regulatory-style summary tables 
******************************************************************************************************************/

/* CREATE A LIBRARY */

%let root = ~/sasuser.v94;
libname results "&root/results";

/* IMPORT DATASETS */

proc import datafile="&root/sim_data.csv" 
    out=results.sim_data
    dbms=csv
    replace;
    guessingrows=max;
run;

proc import datafile="&root/sim_data_un.csv"
    out=results.sim_data_un
    dbms=csv
    replace;
    guessingrows=max;
run;

/* MACRO TO FIT THE MODEL */

%macro run_mixed(indata=, outprefix=, random=0);

ods exclude all;
ods output
    lsmeans = &outprefix._lsm
    diffs   = &outprefix._diff
    covparms= &outprefix._cov;

proc mixed data=&indata;
    by parameter;
    class subject treatment(ref='R') sequence period;

    %if &random=0 %then %do;
        model logpk = treatment sequence period subject(sequence) / ddfm=kr;
    %end;

    %if &random=1 %then %do;
        model logpk = treatment sequence period / ddfm=kr;
        random subject(sequence);
    %end;

    lsmeans treatment / pdiff cl alpha=0.1;
run;

ods exclude none;

%mend;

/* MACRO TO RUN THE MODELS */

%macro run_all;

%run_mixed(indata=results.sim_data,    outprefix=fe_bal,   random=0);
%run_mixed(indata=results.sim_data_un, outprefix=fe_unbal, random=0);

%run_mixed(indata=results.sim_data,    outprefix=me_bal,   random=1);
%run_mixed(indata=results.sim_data_un, outprefix=me_unbal, random=1);

%mend;

%run_all;

/* N PER TREATMENT */

%macro count_n(indata=, out=);

proc sql;
create table &out as
select parameter,
       treatment,
       count(distinct subject) as n
from &indata
group by parameter, treatment;
quit;

%mend;

%count_n(indata=results.sim_data,    out=n_bal);
%count_n(indata=results.sim_data_un, out=n_unbal);

/* ASSEMBLE THE TABLE */
%macro assemble(prefix=, ndata=, out=);

/* Minimal sorts */
proc sort data=&prefix._lsm;   by parameter treatment; run;
proc sort data=&prefix._diff;  by parameter; run;
proc sort data=&prefix._cov;   by parameter; run;
proc sort data=&ndata;         by parameter treatment; run;

data &out;
    length treatment $20 group $30;
    merge &prefix._lsm (rename=(estimate=log_lsm stderr=log_se_lsm))
          &ndata (rename=(treatment=_trttemp)) /* solve length issues by renaming */
          &prefix._diff(rename=(estimate=log_ratio stderr=log_se_ratio lower=log_low upper=log_high))
          &prefix._cov (where=(upcase(covparm)="RESIDUAL") rename=(estimate=resid_var));
    by parameter;
    
    /* Fix treatment length/mismatch during merge logic */
    length treatment $20 group $30;
    treatment = _trttemp;
    
    /* Perform all back-transformations */
    adj_gmean = exp(log_lsm);
    adj_gse   = exp(log_se_lsm);
    ratio     = exp(log_ratio)* 100;
    gse       = exp(log_se_ratio);
    lower     = exp(log_low)* 100;
    upper     = exp(log_high)* 100;
    gcv       = (sqrt(exp(resid_var) - 1))* 100;

    /* Endpoint grouping */
    select(upcase(parameter));
        when ("AUC0_TZ","CMAX") group="Primary endpoints";
        when ("AUCINF_PRED")    group="Secondary endpoint";
        otherwise               group="Other";
    end;

    /* Wipe duplicate stats for cleaner reporting */
    if not first.parameter then call missing(ratio, lower, upper, gcv, log_se_ratio);
    
    drop _trttemp resid_var log_: ;
run;
%mend;

%assemble(prefix=fe_bal,   ndata=n_bal,   out=results.table_fe_bal);
%assemble(prefix=fe_unbal, ndata=n_unbal, out=results.table_fe_unbal);

%assemble(prefix=me_bal,   ndata=n_bal,   out=results.table_me_bal);
%assemble(prefix=me_unbal, ndata=n_unbal, out=results.table_me_unbal);

/* PROC REPORT MACRO - PRODUCE PUBLICATION-STYLE TABLES */

%macro make_report(data=, model=, balance=);

%let subjtxt = %sysfunc(ifc(&model=fixed, fixed effect, random effect));

title "Adjusted geometric means and relative bioavailability
of treatment (T) vs reference (R) with subject as &subjtxt - &balance dataset";

proc report data=&data nowd headline split="|";
    column group parameter treatment n
           adj_gmean adj_gse
           ratio gse lower upper gcv;

    define group / group "Endpoint";
    define parameter / group "PK Parameter";

    define treatment / display;
    define n / display;

    define adj_gmean / display format=8.2 "gMean";
    define adj_gse   / display format=8.2 "gSE";

    define ratio     / display format=8.2 "Ratio (T/R) %";
    define gse       / display format=8.2 "gSE";
    define lower     / display format=8.2 "Lower (%)";
    define upper     / display format=8.2 "Upper (%)";
    define gcv       / display format=8.1 "gCV (%)";
run;

%mend;

%make_report(data=results.table_fe_bal,   model=fixed, balance=balanced);
%make_report(data=results.table_me_bal,   model=mixed, balance=balanced);

%make_report(data=results.table_fe_unbal, model=fixed, balance=unbalanced);
%make_report(data=results.table_me_unbal, model=mixed, balance=unbalanced);

/* CLEAN UP TEMPORARY DATASETS */
proc datasets library=work nolist;
    delete fe_bal_: fe_unbal_: me_bal_: me_unbal_: n_bal n_unbal;
quit;