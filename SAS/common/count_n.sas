/*****************************************************************************************************************
Macro:        count_n 
Purpose:      Calculates the number of distinct subjects per treatment and PK parameter.
              Ensures N is accurately reflected in the final table, accounting for potential missing data.
Author:       Bianca Gasparini
Input:        Analysis dataset (results.sim_data or results.sim_data_un).
Output:       A summary dataset (&out) containing counts (n) by parameter and treatment.
******************************************************************************************************************/

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