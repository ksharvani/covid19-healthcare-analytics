/* Covid Dataset creation - Fact and Dim tables creation*/

create or replace table `Covid_Analytics.FACT_Covid19` as

select 
date,
country_code,
country_name,
population,
aggregation_level,

new_confirmed,
cumulative_confirmed,

new_deceased,
cumulative_deceased,

new_hospitalized_patients,
cumulative_hospitalized_patients,

new_intensive_care_patients,
cumulative_intensive_care_patients,

new_persons_vaccinated,
cumulative_persons_vaccinated,

new_persons_fully_vaccinated,
cumulative_persons_fully_vaccinated,

new_recovered,
cumulative_recovered

from `bigquery-public-data.covid19_open_data.covid19_open_data`
WHERE aggregation_level = 0

/*Dim_Country*/
create or replace table `Covid_Analytics.DIM_Country` as
select distinct country_code, country_name, population
from `Covid_Analytics.FACT_Covid19`


/*Dim_Date*/
create or replace table `Covid_Analytics.DIM_Date` as
select distinct date as Date_Key,
extract(Year from Date) as Year,
extract(Quarter from Date) as Quarter,
extract(Month from date) as Month_Number,
Format_Date('%B', date) as Month_Name,
Format_Date('%b', date) as Month_Short_Name,
extract(week from date) as Week_number,
extract(Day from date) as Day,
Format_Date('%A', date) as Day_Name
from `Covid_Analytics.FACT_Covid19`


