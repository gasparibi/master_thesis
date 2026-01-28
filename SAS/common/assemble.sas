/*****************************************************************************************************************
Macro:        assemble 
Purpose:      Merges model outputs, performs log-to-linear back-transformations, calculates 
              geometric CV (gcv), and applies endpoint grouping logic.
Author:       Bianca Gasparini
Input:        ODS outputs from PROC MIXED (_lsm, _diff, _cov) and subject counts (&ndata).
Output:       A finalized dataset (&out) ready for reporting, with statistics scaled to percentages.
Note:         Uses 'first.parameter' logic to prevent duplicate display of ratio/CV statistics.
******************************************************************************************************************/

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