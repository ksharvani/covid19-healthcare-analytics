# Power BI Data Model

## Overview

The COVID-19 Healthcare Analytics report uses a dimensional data model with one fact table and two dimension tables. This structure supports country-level and time-based analysis across the report's five pages.

## Tables

### 1. FACT_Covid19

The central fact table contains country-level COVID-19 observations over time.

Key metrics include:
- New and cumulative confirmed cases
- New and cumulative deaths
- Fully vaccinated people
- Recovered patients
- Hospitalized patients
- ICU patients

**Data grain:** One row per country per date for the selected country-level dataset.

### 2. DIM_Country

The country dimension contains country-level descriptive attributes, including country names and population information.

It supports country slicers, comparisons, rankings, and population-based vaccination calculations.

### 3. DIM_Date

The date dimension contains calendar attributes used for time-based analysis, including year, month, month number, quarter, and other date components.

It supports date filtering, monthly trends, and time-based comparisons.

## Relationships

The model uses one-to-many relationships from the dimension tables to the fact table.

- `DIM_Country` → `FACT_Covid19`
- `DIM_Date` → `FACT_Covid19`

Relationships use single-direction filtering from dimensions to the fact table.

## Why This Model?

- Separates descriptive attributes from analytical observations
- Supports consistent filtering across report pages
- Reduces unnecessary duplication of dimension attributes in the fact table
- Makes DAX measures easier to organize and maintain
- Supports country comparisons and time-series analysis

## Data Source

Google BigQuery public dataset:

`bigquery-public-data.covid19_open_data.covid19_open_data`

The country-level data was prepared in BigQuery and imported into Power BI for analysis.

## Data Quality Considerations

Some healthcare and vaccination metrics have missing values. Cumulative vaccination figures can also exceed population estimates in certain records. These limitations should be considered when interpreting comparisons and dashboard results.
