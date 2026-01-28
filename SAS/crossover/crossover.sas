/*****************************************************************************************************************
Macro:        crossover.sas
Purpose:      Model fitting macro for 2x2 crossover designs.
              Supports fixed-effects (subject as fixed) and mixed-effects (subject as random).
Author:       Bianca Gasparini
Input:        Dataset containing: subject, treatment, sequence, period, and log-transformed PK (logpk).
Output:       SAS datasets: lsmeans (&outprefix._lsm), diffs (&outprefix._diff), and covparms (&outprefix._cov).
******************************************************************************************************************/

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