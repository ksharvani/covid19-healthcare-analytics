/*Identifying only necessary columns from the hundreds of columns in open data to understand the granularity and at what level the data is unique at. Gave importance to date, country or the area and only 2 metrics*/
SELECT
date,country_code,
country_name,
subregion1_name,
subregion2_name,
aggregation_level,
new_confirmed,
new_deceased
FROM `bigquery-public-data.covid19_open_data.covid19_open_data`
LIMIT 100


/*Checked if the total rows in the data and the combination or concatenation of date and country columns match the total rows. If the number matches, it means that one row = one country per date.*/ 
SELECT
COUNT(*) as total_rows,
COUNT(DISTINCT CONCAT(
CAST(date AS STRING),
country_name
)) distinct_rows
FROM `bigquery-public-data.covid19_open_data.covid19_open_data`
WHERE aggregation_level = 0


/* to understand aggregation levels*/
select distinct aggregation_level,
count(*) as Total_rows from `bigquery-public-data.covid19_open_data.covid19_open_data`
group by aggregation_level 
order by aggregation_level 

/* checking for duplicates at country level*/
select date, country_name,count(*) as records from `bigquery-public-data.covid19_open_data.covid19_open_data`
where aggregation_level = 0
group by 1,2
having count(*) > 1

/* Violation Check 1: Ideal Scenario: Tested cases should exceed the confirmed cases.*/
SELECT
    date,
    country_name,
    new_confirmed,
    safe_cast(new_tested AS INTEGER) new_tested
FROM `bigquery-public-data.covid19_open_data.covid19_open_data`
WHERE aggregation_level = 0
    AND new_confirmed IS NOT NULL
    AND new_tested IS NOT NULL
    AND new_confirmed > safe_cast(new_tested AS INTEGER)
ORDER BY date;

/* Checked the violation %. It is <5% hence it is good testing coverage. our reslt is 1.17%*/
select countif(new_confirmed > safe_cast(new_tested AS INTEGER)) as Violations, Count(*) as Total_records,
round(safe_divide(countif(new_confirmed > safe_cast(new_tested AS INTEGER))*100,Count(*)),2)
FROM `bigquery-public-data.covid19_open_data.covid19_open_data`
WHERE aggregation_level = 0
    AND new_confirmed IS NOT NULL
    AND new_tested IS NOT NULL


/*Negative Values check*/
select date, country_name, new_confirmed from `bigquery-public-data.covid19_open_data.covid19_open_data`
WHERE aggregation_level = 0
  AND new_confirmed < 0


/*Data Quality Check: Ideal situation: Vaccinated persons should not be greater than total population*/
SELECT
    country_name,
    MAX(cumulative_persons_vaccinated) AS vaccinated,
    MAX(population) AS population
FROM `bigquery-public-data.covid19_open_data.covid19_open_data`
WHERE aggregation_level = 0
GROUP BY country_name
HAVING vaccinated > population;

/* Vaccination %*/
SELECT
    country_name,
    MAX(cumulative_persons_vaccinated) AS vaccinated,
    MAX(population) AS population,
    ROUND(
        MAX(cumulative_persons_vaccinated) * 100.0 /
        MAX(population),
        2
    ) AS vaccination_pct
FROM `bigquery-public-data.covid19_open_data.covid19_open_data`
WHERE aggregation_level = 0
GROUP BY country_name
HAVING vaccinated > population
ORDER BY vaccination_pct DESC;

/*Phase 2: Data Profiling*/
select count(*) from `bigquery-public-data.covid19_open_data.covid19_open_data`
WHERE aggregation_level = 0 /* Total records: 22,756,333, total records where agg_lvl = 0: 243786*/

Select distinct country_name from `bigquery-public-data.covid19_open_data.covid19_open_data`
WHERE aggregation_level = 0 /*total countries: 246*/

select max(date), min(date) from `bigquery-public-data.covid19_open_data.covid19_open_data`
WHERE aggregation_level = 0 /* data range: 2020-01-01 to 2022-09-17*/

select countif(new_confirmed is null) as null_cases,
countif(new_deceased is null) as null_deaths,
countif(population is null) as null_population
from `bigquery-public-data.covid19_open_data.covid19_open_data`
WHERE aggregation_level = 0 /* missing values*/


