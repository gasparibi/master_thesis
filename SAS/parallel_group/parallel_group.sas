/*****************************************************************************************************************
Macro:        parallel_group.sas
Purpose:      Model fitting macro for parallel-group designs.
              Uses REPEATED / GROUP=TREATMENT to allow for heteroscedasticity (unequal variances) between groups.
Author:       Bianca Gasparini
Input:        Dataset containing: treatment and log-transformed PK (logpk).
Output:       SAS datasets: lsmeans (&outprefix._lsm), diffs (&outprefix._diff), and covparms (&outprefix._cov).
******************************************************************************************************************/

/* MACRO TO FIT THE MODEL */

%macro run_mixed_pg(indata=, outprefix=);

ods exclude all;
ods output
    lsmeans = &outprefix._lsm
    diffs   = &outprefix._diff
    covparms= &outprefix._cov;

proc mixed data=&indata;
    by parameter;
    class treatment(ref='R');

    model logpk = treatment / ddfm=kr;
    repeated / type = un group = treatment; /* It specifies un unstructured covariance matrix separately for each 
                                               treatment group, allowing the residual variance to differ by group */
    lsmeans treatment / pdiff cl alpha=0.1;
run;

ods exclude none;

%mend;