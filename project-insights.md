# COVID-19 Healthcare Analytics — Key Insights

## Project Objective

Analyze global COVID-19 data to understand the progression of cases, deaths, vaccination coverage, and healthcare outcomes across countries and over time.

## Key Analytical Findings

### 1. COVID-19 Trends Vary Over Time
Monthly case trends and seven-day rolling averages help identify periods of increasing or decreasing reported infections. Month-over-month comparisons provide additional context for changes in reported cases.

### 2. Country-Level Outcomes Differ
Comparing countries using confirmed cases, reported deaths, and case fatality rate (CFR) reveals differences in reported pandemic outcomes. These metrics should be interpreted alongside differences in reporting practices and data completeness.

### 3. Vaccination Coverage Requires Careful Interpretation
The analysis compares fully vaccinated population estimates across countries. Some cumulative vaccination figures exceed reported population estimates, highlighting the need to validate source data before making direct comparisons.

### 4. Healthcare Metrics Have Missing Values
Hospitalization, ICU, and recovery metrics contain substantial missing data in the source dataset. Country rankings and trend comparisons should therefore be interpreted with caution.

### 5. Data Quality Is an Important Part of Analytics
The project includes SQL validation checks for missing values, aggregation levels, record grain, and consistency between fact and dimension tables. These checks help identify limitations before presenting results in Power BI.

## Business Intelligence Value

The Power BI dashboard brings multiple analytical perspectives into one report:

- KPI monitoring for confirmed cases, deaths, vaccination coverage, and CFR
- Time-series analysis of reported cases and recoveries
- Country comparisons and rankings
- Healthcare outcome analysis covering hospitalization and ICU metrics
- Interactive filtering to explore countries and reporting periods

## Recommendations

- Validate cumulative metrics and population denominators before comparing countries.
- Display data completeness alongside healthcare indicators where possible.
- Use consistent reporting periods for country comparisons.
- Treat missing values as unknown rather than assuming they represent zero.
- Review unusual values before interpreting them as meaningful trends.

## Project Limitations

The analysis relies on a public dataset whose completeness and reporting practices vary across countries and dates. The findings are descriptive and should not be interpreted as proof of causal relationships or as current public-health statistics.

## Tools Used

Google BigQuery SQL | Microsoft Power BI | Power Query | DAX | Dimensional Data Modeling
