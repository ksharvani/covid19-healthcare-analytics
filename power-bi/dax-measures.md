# Power BI DAX Measures

This document describes selected DAX measures used in the COVID-19 Healthcare Analytics dashboard.

## 1. Total Confirmed Cases

```dax
Total Cases =
SUM(FACT_Covid19[new_confirmed])
```

**Purpose:** Calculates the total reported new confirmed cases for the selected filters and reporting period.

## 2. Total Deaths

```dax
Total Deaths =
SUM(FACT_Covid19[new_deceased])
```

**Purpose:** Calculates reported new deaths for the selected filters and reporting period.

## 3. Case Fatality Rate (CFR)
```dax
CFR = DIVIDE([Total Deaths],[Total Cases],0)
```
**Purpose:** Measures the proportion of confirmed cases represented by reported deaths. The calculation depends on the selected reporting period and filter context.

## 4. Vaccination Percentage
```dax

Total Fully Vaccinated = SUMX(
    VALUES(DIM_Country[country_name]),
    CALCULATE(MAX(FACT_Covid19[cumulative_persons_fully_vaccinated])
    )
)

Vaccination % = DIVIDE([Total Fully Vaccinated], [Total Population],0)
```
**Purpose:** Compares fully vaccinated people with the population to show vaccination coverage.

The dashboard uses a measure that aggregates the latest available cumulative fully vaccinated value at the country level before calculating the percentage.

## 5. Month-over-Month Analysis
```dax
Monthly New Cases = SUM(FACT_Covid19[new_confirmed])

MOM Growth % = 
        Var CurrentMonthCases = [Monthly New Cases]
        Var PrevMonthCases = 
            CALCULATE(
                [Monthly New Cases],
                DATEADD(DIM_Date[Date_Key], -1, MONTH)
            )
            RETURN
            DIVIDE( CurrentMonthCases - PrevMonthCases, PrevMonthCases, 0)
```

**Purpose:** Compares the current month's new confirmed cases with the previous month's value to identify increases or decreases.

## 6. Seven-Day Rolling Average
```dax
7 day Rolling Avg Cases = AVERAGEX(
    DATESINPERIOD(DIM_Date[Date_Key],
    MAX(DIM_Date[Date_Key]),
    -7,
    DAY), 
    CALCULATE([Total Cases])
    )
```
**Purpose:** Smooths daily case fluctuations to make short-term trends easier to interpret.

## 7. Country Ranking
Selected Ranking Metric = 
SWITCH(
    SELECTEDVALUE('Top N Metric'[Metric]),
    "Confirmed Cases", [Total Cases],
    "Deaths", [Total Deaths],
    "Case Fatality Rate",[CFR],
    "Vaccination %",[Vaccination %]
)
**Purpose:** Ranks countries using selected performance metrics, supporting comparative analysis.

## Filter Context

Measures respond to the report's applicable filters, including country and date selections. The data model uses country and date dimension tables to support analysis across report pages.

