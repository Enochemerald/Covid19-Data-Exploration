# COVID-19 Data Exploration 

## Project Description
This project is a comprehensive exploration of a COVID-19 dataset aimed at uncovering insights about the pandemic's spread, severity, and timeline using MySQL. The dataset includes information such as the number of confirmed cases, deaths, and recoveries across various regions and dates. The goal is to clean, transform, and analyze this data to support public health decisions and research.

The project script automates key data processing steps like handling missing values, transforming dates, and deriving critical metrics that enable further visualization and reporting.

## Objective
The primary objectives of this project are:
1. **Data Cleaning**: Identify and correct any missing, null, or incorrect data.
2. **Data Transformation**: Standardize formats, particularly date fields, to ensure consistent analysis.
3. **Exploratory Analysis**: Extract meaningful insights from the data to track the progression and impact of COVID-19 over time and across regions.

## Methodology
1. **Database Initialization**:
   - Creation of the `c19virus_db` database and `covid_data` table.
   - Loading the raw dataset into the database for analysis.
   
2. **Data Cleaning**:
   - Queries to check for null or missing values in critical columns (`Confirmed`, `Deaths`, `Recovered`, `Date`, `Province`).
   - Update operations to replace missing numerical values with `0` or other relevant defaults.
   - Transformation of the `Date` column from string format to `DATE` type for accurate time-series analysis.
   
3. **Data Exploration**:
   - Counting distinct provinces affected to understand geographical spread.
   - Querying start and end dates to determine the timeframe covered by the dataset.
   - Assessing the completeness of the dataset by counting the number of rows and months present.

## Key Findings 
- **Geographical Spread**: The number of unique provinces affected gives an overview of how widespread the pandemic is.
- **Timeline**: The earliest and latest dates in the dataset show the progression timeline of the pandemic.
- **Data Quality**: Identifying and handling missing data ensures more accurate downstream analysis.

## Example Queries
### 1. Identifying Missing Data
```sql
SELECT * FROM covid_data 
WHERE Province IS NULL OR `Country/Region` IS NULL 
      OR Latitude IS NULL OR Longitude IS NULL 
      OR `Date` IS NULL OR Confirmed IS NULL 
      OR Deaths IS NULL OR Recovered IS NULL;
