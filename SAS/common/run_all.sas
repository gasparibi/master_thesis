/*****************************************************************************************************************
Macro:        run_all 
Purpose:      Wrapper macro to execute the full modeling suite. 
              Runs fixed-effects (random=0) and mixed-effects (random=1) models on both 
              balanced and unbalanced crossover datasets.
Author:       Bianca Gasparini
Input:        results.sim_data, results.sim_data_un
Output:       Sets of ODS output datasets for each model/dataset combination.
******************************************************************************************************************/

/* MACRO TO EXECUTE THE MODELS */

%macro run_all;

%run_mixed(indata=results.sim_data,    outprefix=fe_bal,   random=0);
%run_mixed(indata=results.sim_data_un, outprefix=fe_unbal, random=0);

%run_mixed(indata=results.sim_data,    outprefix=me_bal,   random=1);
%run_mixed(indata=results.sim_data_un, outprefix=me_unbal, random=1);

%mend;