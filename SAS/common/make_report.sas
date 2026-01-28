/*****************************************************************************************************************
Macro:        make_report 
Purpose:      Generates publication-quality tables using PROC REPORT. 
              Applies standard PK formatting (gMean, gCV, Ratio %) and dynamic titles.
Author:       Bianca Gasparini
Input:        Final assembled dataset (&data).
Output:       Standardized summary table of bioavailability results.
******************************************************************************************************************/

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