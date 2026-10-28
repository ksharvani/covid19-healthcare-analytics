/*Level 1 Queries*/
/* 1. Which countries were most affected by COVID overall? or Which 10 countries reported the highest total confirmed cases?*/

/*Option 1: Using new_confimred column which is a daily metric*/
select distinct country_name as Country, sum(new_confirmed) as Affected_Covid_Patients
from `Covid_Analytics.FACT_Covid19`
group by 1
order by 2 desc
limit 10

/*Option 2: Using cumulative_confirmed column which is a daily metric*/

WITH latest_date as (
  select *, row_number() over (partition by Country_name order by date desc) as RN
  from `Covid_Analytics.FACT_Covid19`
  where cumulative_confirmed is Not null
)
select date, country_name, cumulative_confirmed as Affected_Covid_Patients
from latest_date
where RN = 1
order by 3 desc
limit 10

/* 2. Which countries experienced the highest mortality burden? or Which 10 countries reported the highest total deaths?*/
WITH latest_date as(
  select *, row_number() over (partition by country_name order by date desc) as RN
  from `Covid_Analytics.FACT_Covid19`
  where cumulative_deceased is Not null
)
select date, country_name, cumulative_deceased as Deaths
from latest_date
where RN = 1
order by 3 desc
limit 10

/*Option 2*/
select country_name, max(cumulative_deceased) as Deaths
from `Covid_Analytics.FACT_Covid19`
where cumulative_deceased is Not null
group by 1
order by 2 desc
limit 10

/*3. Which countries were most successful in vaccinating their population? or Which countries had the highest vaccination coverage?*/

/*quality check: to find out what is the nulls difference between both the columns and bcause the difference is very less I ahve chosen to take cumulative column for analysis*/
select country_name, 
Countif(new_persons_fully_vaccinated is NULL) as daily_nulls,  
countif(cumulative_persons_fully_vaccinated is null) as cum_nulls
from `Covid_Analytics.FACT_Covid19`
group by 1


select a.country_name,
b.population,
max(a.cumulative_persons_fully_vaccinated) as Fully_vaccinated_patients,
round(
  safe_divide(
    max(a.cumulative_persons_fully_vaccinated)*100,b.population)
    ,0) as Vaccination_pct,
Least(
    round(
  safe_divide(
    max(a.cumulative_persons_fully_vaccinated)*100,b.population)
    ,0),
    100) as Vaccination_pct_capped
from `Covid_Analytics.FACT_Covid19` as a
left join
`covid-19-analysis-499708.Covid_Analytics.DIM_Country` as b
on a.country_code = b.country_code
where cumulative_persons_fully_vaccinated is not null
and b.population > 1000000 /*this avoids the countries with low population but it can still give us higher percentage and occupy top 10*/
group by 1,2
order by 4 desc
limit 10

/* 4. What was the global number of new confirmed cases by month? */


select b.Year, b.month_name as Month, b.Month_Number, sum(coalesce(a.new_confirmed,0)) as New_Confirmed_Cases
from `Covid_Analytics.FACT_Covid19` as a
left join
`covid-19-analysis-499708.Covid_Analytics.DIM_Date` as b
on a.date = b.Date_Key
group by 1,2,3
order by 1 desc, 3 asc

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT CONCAT(country_code, CAST(date AS STRING))) AS distinct_country_date_rows
FROM `Covid_Analytics.FACT_Covid19`;



SELECT
    MAX(monthly_cases) AS highest_monthly_cases
FROM (
    SELECT
        b.year,
        b.month_number,
        SUM(COALESCE(a.new_confirmed,0)) AS monthly_cases
    FROM `Covid_Analytics.FACT_Covid19` a
    JOIN `Covid_Analytics.DIM_Date` b
        ON a.date = b.date_key
    GROUP BY
        b.year,
        b.month_number
);


select count(*) as total_rows, count(distinct date_key) as unique_dates
from `covid-19-analysis-499708.Covid_Analytics.DIM_Date`

SELECT
    COUNT(*) AS fact_rows
FROM `Covid_Analytics.FACT_Covid19`;

SELECT
    COUNT(*) AS joined_rows
FROM `Covid_Analytics.FACT_Covid19` a
JOIN `Covid_Analytics.DIM_Date` b
    ON a.date = b.date_key;


select distinct date_key as Date, count(*)
from `covid-19-analysis-499708.Covid_Analytics.DIM_Date`
group by 1
having count(*) > 1

/*level 2*/
/*For India, how did confirmed cases trend over time?*/

select b.Year, b.month_name as Month, b.Month_Number, sum(coalesce(a.new_confirmed,0)) as New_Confirmed_Cases
from `Covid_Analytics.FACT_Covid19` as a
left join
`covid-19-analysis-499708.Covid_Analytics.DIM_Date` as b
on a.date = b.Date_Key
where country_name = 'India'
group by 1,2,3
order by 1 desc, 3 asc

/*if we need cumiulative total confirmed cases per month towards month end*/

WITH month_end as (
  select country_name as Country,
  extract(Year from date) as Year,
  extract(Month from date) as Month,
  max(date) as Max_date
  from `Covid_Analytics.FACT_Covid19`
  where country_name = 'India'
  group by 1,2,3
)
select m.Year, m.Month, f.cumulative_confirmed
from month_end as m
left join
`Covid_Analytics.FACT_Covid19` as f
on f.country_name = m.Country
and f.date = m.Max_date
order by 1,2


/*MOM Growth/decline of monthly cases % of India*/

WITH monthly_cases as(
  select b.year as Year,
  b.Month_name as Month,
  b.Month_number,
  coalesce(sum(a.new_confirmed),0) as month_cases
  from `covid-19-analysis-499708.Covid_Analytics.FACT_Covid19` as a
  left join
  `covid-19-analysis-499708.Covid_Analytics.DIM_Date` as b
  on a.date = b.Date_Key
  --where a.country_name = 'India'
  where b.year = 2020
  group by 1,2,3
  order by 1,2,3
)
select Year,Month,month_cases,
LAG(month_cases) over (order by Year, Month_number) as Previous_month_cases,
round(
  safe_divide(month_cases - LAG(month_cases) over (order by Year, Month_number),
  LAG(month_cases) over (order by Year, Month_number))*100,2
) as Growth_pct
from monthly_cases
order by year, Month_Number


/*Which countries experienced the largest single-day spike in new cases? i.e. Which countries had the highest single-day reported cases?*/----

WITH daily_cases as(
  select a.date, a.country_name, sum(coalesce(a.new_confirmed,0)) as confirmed_cases
  from `covid-19-analysis-499708.Covid_Analytics.FACT_Covid19` as a
  group by 1,2
),
rank as(
  select *, row_number() over (partition by country_name order by confirmed_cases desc) as RN
  from daily_cases
)
select * except(RN)
from rank
where RN = 1
order by confirmed_cases desc
limit 20


/*What is the 7-day rolling average of new confirmed cases?*/
WITH Daily_cases as(
  select distinct date, country_name, sum(coalesce(new_confirmed,0)) as Confirmed_cases
  from `covid-19-analysis-499708.Covid_Analytics.FACT_Covid19` as a
  --where country_name = 'India'
  group by 1,2
  order by 3 desc
)
select distinct date, country_name,Confirmed_cases,
        Avg(Confirmed_cases) over (partition by country_name order by date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as Rolling_7_day_avg
        from Daily_cases
        
/*Which countries had increasing case trends for 3 consecutive months?*/
WITH monthly_cases as(
  select a.country_name, 
  extract(Year from date) as Year,
  b.Month_name, b.Month_number,
 sum(coalesce(new_confirmed,0)) as Monthly_confirmed_cases
  from `covid-19-analysis-499708.Covid_Analytics.FACT_Covid19` as a
  left join
  `covid-19-analysis-499708.Covid_Analytics.DIM_Date` as b
  on a.date = b.Date_Key
  group by 1,2,3,4
),
Monthly_lag as (
  select *, 
  LAG(Monthly_confirmed_cases,1) over (partition by country_name order by Year, Month_number) as Prev_month_cases,
  LAG(Monthly_confirmed_cases,2) over (partition by country_name order by Year, Month_number) as Prev2_month_cases,
  from monthly_cases
)
select * from Monthly_lag
where Monthly_confirmed_cases > Prev_month_cases
and Prev_month_cases > Prev2_month_cases
ORDER BY
    country_name,
    year,
    month_number;

/*level 3: Healthcare Analytics*/

/*Which countries had the highest Case Fatality Rate (CFR)?*/

/*Case Fatality rate means "Out of all the people who were confirmed to have COVID-19, what percentage died?"
It measures how deadly the disease was among confirmed cases, not how many people died overall.
The formula is:
CFR= Total Deaths   
    ---------------   ×100
	​Total Confirmed Cases*/


WITH total_cases as(
  select country_name, max(cumulative_confirmed) as Total_confirmed_Cases, max(cumulative_deceased) as Total_deaths
  from `covid-19-analysis-499708.Covid_Analytics.FACT_Covid19`
  group by 1
)
select *, 
round(safe_divide(Total_deaths,Total_confirmed_Cases)*100,2) as CFR
from total_cases
where Total_confirmed_Cases > 10000
order by CFR desc
limit 10

/*Approach 2 - most recommended and safe*/
WITH latest_record_ranking as(
  select *, 
  row_number() over (partition by country_name order by date desc) as RN
  from `covid-19-analysis-499708.Covid_Analytics.FACT_Covid19`
  where cumulative_confirmed is not null
  and cumulative_deceased is not null
)
select country_name,date, cumulative_confirmed, cumulative_deceased,
round(safe_divide(cumulative_deceased,cumulative_confirmed)*100,2) as CFR
from latest_record_ranking
where RN = 1
and cumulative_confirmed > 10000
order by CFR desc
limit 10

/*Which countries had the highest hospitalization burden?*/

/*3 ways to solve this.*/
/*Option 1: Which countries had the highest total number of COVID hospitalizations throughout the pandemic?*/

WITH total_cases as(
  select country_name, date,
  cumulative_hospitalized_patients,
  row_number() over (partition by country_name order by date desc) as RN
  from `covid-19-analysis-499708.Covid_Analytics.FACT_Covid19`
  where cumulative_hospitalized_patients is not null
)
select country_name, cumulative_hospitalized_patients as total_hospitalized_patients
from total_cases
where RN = 1
order by cumulative_hospitalized_patients desc


/*Option 2: Which countries experienced the largest one-day surge in hospital admissions?*/

WITH Daily_cases as(
select country_name, date, sum(coalesce(new_hospitalized_patients,0)) as Daily_hospitalized_patients 
from `covid-19-analysis-499708.Covid_Analytics.FACT_Covid19`
where new_hospitalized_patients is not null
--and country_name = "Argentina"
group by 1,2
),
Ranked as(
  select *, 
  rank() over (partition by country_name order by Daily_hospitalized_patients desc) as RN
  from Daily_cases
)
select * except(RN)
from Ranked
where RN = 1
order by Daily_hospitalized_patients desc

/*Option 3: Hospitalization Rate*/

WITH Latest_hospitalization as(
select country_name, date, cumulative_confirmed, cumulative_hospitalized_patients
from `covid-19-analysis-499708.Covid_Analytics.FACT_Covid19`
where cumulative_confirmed is not null
and cumulative_hospitalized_patients is not null
and cumulative_confirmed > 10000
),
Ranked as (
  select *, 
  row_number() over (partition by country_name order by date desc) as RN
  from Latest_hospitalization
)
select country_name, date,
 cumulative_confirmed, cumulative_hospitalized_patients,
 round(safe_divide(cumulative_hospitalized_patients, cumulative_confirmed)*100,2) as Hospitalization_rate
 from Ranked
 where RN = 1
 order by Hospitalization_rate desc /*Remove japan from consideration as the values are not realistic. Below is the checks done to eliminate Japan. Japan has confirmed cases less than hospitalized patients which is practically not possible*/


/*select country_name, date,  cumulative_confirmed,
    cumulative_hospitalized_patients
FROM `Covid_Analytics.FACT_Covid19`
WHERE country_name = 'Japan'
and cumulative_hospitalized_patients > cumulative_confirmed
ORDER BY date DESC;

SELECT
    MAX(cumulative_confirmed),
    MAX(cumulative_hospitalized_patients)
FROM `Covid_Analytics.FACT_Covid19`
WHERE country_name = 'Japan';*/


/*Which countries had the highest ICU burden?*/
/*Option 1: Which countries experienced the largest one-day surge in ICU admissions?*/

WITH ICU_Patients as (
  select country_name, date, sum(coalesce(new_intensive_care_patients,0)) as Total_ICU_Patients
  from `Covid_Analytics.FACT_Covid19`
  where new_intensive_care_patients is not null
  group by 1,2
),
ranked as (
  select *, row_number() over (partition by country_name order by Total_ICU_Patients desc) as RN
  from ICU_Patients
)
select country_name, date, Total_ICU_Patients
from ranked
where RN = 1
order by Total_ICU_Patients desc


/*Which countries showed improving recovery rates over time?*/

WITH max_month as(
  select country_name, 
  extract(Year from date) as Year,
  extract(Month from date) as Month,
  max(date) as Max_date
  from `covid-19-analysis-499708.Covid_Analytics.FACT_Covid19`
  group by 1,2,3
),
monthly_recovery as(
  select a.*, b.cumulative_confirmed, b.cumulative_recovered,
  Round(safe_divide(b.cumulative_recovered,b.cumulative_confirmed)*100,2) as Recovery_Rate
  from max_month as a
  left join
  `covid-19-analysis-499708.Covid_Analytics.FACT_Covid19` as b
  on a.Max_date = b.date
  where cumulative_confirmed is not null
  and cumulative_recovered is not null
  and cumulative_confirmed >= cumulative_recovered
),
recovery_trend as (
  select *, 
  LAG(Recovery_Rate) over (partition by country_name order by Year,Month desc) as prev_month_rate,
  row_number() over (partition by country_name order by Year desc, month desc) as RN
  from monthly_recovery
)
select country_name, 
year, month, cumulative_confirmed, cumulative_recovered, Recovery_Rate,  prev_month_rate,
Round(Recovery_Rate - prev_month_rate,2) as Improvement_pct
from recovery_trend
where prev_month_rate is not null
and Rn = 1
and Recovery_Rate > prev_month_rate
order by country_name, 
year, month 

/*Level 4:Vaccination Effectiveness*/

/*Part 1. What percentage of the population is vaccinated?*/
WITH Cumulative_vaccinated as(
  select a.country_name,a.date, b.population, a.cumulative_persons_fully_vaccinated 
  from `covid-19-analysis-499708.Covid_Analytics.FACT_Covid19` as a
  left join
  `covid-19-analysis-499708.Covid_Analytics.DIM_Country` as b
  on a.country_code = b.country_code
  where cumulative_persons_fully_vaccinated is not null
  and b.population > a.cumulative_persons_fully_vaccinated
  --and b.country_name = 'India'
),
ranked as (
select *, row_number() over (partition by country_name order by date desc) as RN
from Cumulative_vaccinated
)
select * except(RN),
Round(safe_divide(cumulative_persons_fully_vaccinated,population)*100,2) as Vaccinated_pct
from ranked
where RN = 1
order by Vaccinated_pct desc

/*Daily Vaccination Drive: How many people were vaccinated each day?*/
select distinct a.date, sum(coalesce(a.new_persons_vaccinated ,0)) as daily_vaccinations_1st_dose,
 sum(coalesce(a.new_persons_fully_vaccinated,0)) as Fully_vaccinated
from `covid-19-analysis-499708.Covid_Analytics.FACT_Covid19` a
where new_persons_vaccinated is not null
group by 1
order by date desc


select distinct a.country_name ,a.date, sum(coalesce(a.new_persons_vaccinated ,0)) as daily_vaccinations_1st_dose,
 sum(coalesce(a.new_persons_fully_vaccinated,0)) as Fully_vaccinated
from `covid-19-analysis-499708.Covid_Analytics.FACT_Covid19` a
where new_persons_vaccinated is not null
group by 1,2
order by date desc


/*Trend Analysis: Is the vaccination campaign accelerating or slowing down?*/
/*7 day rolling average*/
WITH Daily_vaccinations as(
  select country_name, date, sum(coalesce(new_persons_vaccinated,0)) as daily_vaccinated 
  from `covid-19-analysis-499708.Covid_Analytics.FACT_Covid19`
  group by 1,2
)
  select *, 
  Round(avg(daily_vaccinated) over (partition by country_name order by date 
  ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),2) as rolling_avg
  from Daily_vaccinations
  where daily_vaccinated > 0 
  --and country_name = 'India'

/*Month over Month growth of vaccination % or vaccination coverage*/
WITH monthly_vaccinations as(
  select country_name, 
  extract(Year from date) as Year,
  extract(Month from date) as Month,
  sum(coalesce(new_persons_vaccinated,0)) as monthly_vaccinated 
  from `covid-19-analysis-499708.Covid_Analytics.FACT_Covid19`
  group by 1,2,3
),
Prev_month_vaccination as(
select *,
LAG(monthly_vaccinated) over (partition by country_name order by Year, month) prev_month_vaccinations
from monthly_vaccinations
)
select *,
Round(SAFE_DIVIDE(monthly_vaccinated-prev_month_vaccinations,prev_month_vaccinations)*100,2) as MOM_growth
from Prev_month_vaccination
--where monthly_vaccinated > 0
order by country_name, Year, Month


/*Did higher vaccination coverage correlate with lower death rates?*/
WITH latest_country_data AS (
    SELECT
        a.country_name,
        a.date,
        b.population,
        a.cumulative_persons_fully_vaccinated,
        a.cumulative_confirmed,
        a.cumulative_deceased,
        ROW_NUMBER() OVER (
            PARTITION BY a.country_name
            ORDER BY a.date DESC
        ) AS rn
    FROM `covid-19-analysis-499708.Covid_Analytics.FACT_Covid19` a
    JOIN `covid-19-analysis-499708.Covid_Analytics.DIM_Country` b
        ON a.country_name = b.country_name
    WHERE a.cumulative_persons_fully_vaccinated IS NOT NULL
      AND a.cumulative_confirmed IS NOT NULL
      AND a.cumulative_deceased IS NOT NULL
)

SELECT
    country_name,
    population,
    cumulative_persons_fully_vaccinated,
    cumulative_confirmed,
    cumulative_deceased,

    ROUND(
        SAFE_DIVIDE(
            cumulative_persons_fully_vaccinated,
            population
        ) * 100,
        2
    ) AS vaccination_pct,

    ROUND(
        SAFE_DIVIDE(
            cumulative_deceased,
            cumulative_confirmed
        ) * 100,
        2
    ) AS cfr

FROM latest_country_data
WHERE rn = 1
  AND cumulative_persons_fully_vaccinated <= population
ORDER BY vaccination_pct DESC;

/*Compare countries before and after reaching 50% vaccination coverage.*/
WITH Target_population as(
  select a.country_name, b.population,
  safe_divide(b.population,2) as Population_50_pct
  from `covid-19-analysis-499708.Covid_Analytics.FACT_Covid19` a
  left join `covid-19-analysis-499708.Covid_Analytics.DIM_Country` b
  on a.country_code = b.country_code
  group by 1,2
),
earliest_date as(
  select a.country_name, Population_50_pct, b.date, b.cumulative_persons_fully_vaccinated
  from Target_population as a
  left join
  `covid-19-analysis-499708.Covid_Analytics.FACT_Covid19` as b
  on a.country_name = b.country_name
  where b.cumulative_persons_fully_vaccinated >= Population_50_pct
),
ranked as(
  select *, 
  row_number() over (partition by country_name order by date asc) as RN
  from earliest_date
),
Milestone_date as(
select country_name, Population_50_pct, date as earliest_date, cumulative_persons_fully_vaccinated
from ranked
where RN = 1
),
before_after_flag as(
select a.country_name, a.earliest_date, 
coalesce(b.new_confirmed,0) as daily_cases,
COALESCE(b.new_deceased,0) AS daily_deaths,
    case 
      when b.date >= a.earliest_date then 'After'
      when b.date < a.earliest_date then 'Before'
    End as Period
from Milestone_date as a
left join
`covid-19-analysis-499708.Covid_Analytics.FACT_Covid19` as b
 on a.country_name = b.country_name
)
select country_name, period,
   COUNT(*) AS number_of_days,
    ROUND(AVG(daily_cases),2) AS avg_daily_cases,
    ROUND(AVG(daily_deaths),2) AS avg_daily_deaths
FROM before_after_flag
GROUP BY
    country_name,
    period
ORDER BY
    country_name,
    period;


/*Identify countries with High Cases, High vaccinations and low deaths*/

With Latest_record as(
  Select a.Country_name, a.date, a.cumulative_confirmed, a.cumulative_persons_fully_vaccinated, a.cumulative_deceased,
  b.population,  
  round(Safe_divide(cumulative_persons_fully_vaccinated, b.population)*100,2) as Vaccination_pct,
  round(safe_divide(cumulative_deceased, cumulative_confirmed)*100,2) as CFR
  from `covid-19-analysis-499708.Covid_Analytics.FACT_Covid19` as a
  left join
  `Covid_Analytics.DIM_Country` as b
  on a.country_name = b.country_name
  where cumulative_confirmed is not null
  and cumulative_persons_fully_vaccinated is not null
  and cumulative_deceased is not null
),
ranked as(
  select *, row_number() over (partition by country_name order by date desc) as RN
  from Latest_record
),
percentile as (
  select *, 
  NTILE(4) over (order by cumulative_confirmed desc) Total_Cases_group,
  NTILE(4) over (order by Vaccination_pct desc) as Vaccination_group,
  NTILE(4) over (order by CFR ASC) as CFR_group
  from ranked
  where RN =1
)
SELECT 
    Country_name,
    cumulative_confirmed,
    cumulative_persons_fully_vaccinated,
    population,
    Vaccination_pct,
    cumulative_deceased,
    CFR
FROM percentile
WHERE Total_Cases_group = 1
  AND Vaccination_group = 1
  AND CFR_group = 1
ORDER BY cumulative_confirmed DESC;


SELECT
  COUNT(*) AS total_rows,
  COUNT(cumulative_recovered) AS recovered_non_null,
  COUNTIF(cumulative_recovered IS NULL) AS recovered_null,
  COUNT(new_recovered) AS new_recovered_non_null,
  COUNTIF(new_recovered IS NULL) AS new_recovered_null
FROM `covid-19-analysis-499708.Covid_Analytics.FACT_Covid19`;



SELECT
  country_name,
  sum(new_recovered),
FROM `covid-19-analysis-499708.Covid_Analytics.FACT_Covid19`
WHERE new_recovered IS NOT NULL
group by 1
LIMIT 20;



