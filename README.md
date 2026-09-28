# 🌱 Supply Chain GHG Emissions SQL Analysis

## 📌 Project Overview

This project analyzes **supply chain greenhouse gas (GHG) emissions** using **MySQL and SQL**.

The analysis focuses on carbon-emission factors across different industries and commodities. It examines supply-chain emission factors, margin emission factors, combined carbon intensity, greenhouse gases, and emission-intensity tiers.

The project demonstrates practical SQL skills including **data aggregation, filtering, grouping, sorting, joins, subqueries, and window functions**.

---

## 🎯 Project Objectives

The main objectives of this project are to:

* Analyze greenhouse gas emissions across commodities and industries.
* Identify commodities with the highest and lowest carbon intensity.
* Compare **Supply Chain Emission Factors (SEF)** and **Margin Emission Factors (MEF)**.
* Categorize commodities based on carbon-intensity tiers.
* Analyze emissions by individual greenhouse gases.
* Identify commodities with emissions above the overall average.
* Calculate rankings and percentages using SQL window functions.
* Demonstrate practical SQL data-analysis techniques.

---

## 🗄️ Database

The project uses a MySQL database named:

```sql
supply_chain_ghg
```

The database contains two primary tables:

### 1. `emission_factors_co2e`

This table contains commodity-level carbon-emission information.

| Column                   | Description                              |
| ------------------------ | ---------------------------------------- |
| `naics_code`             | NAICS industry/commodity code            |
| `naics_title`            | Industry or commodity name               |
| `useeio_code`            | USEEIO code                              |
| `sef_kgco2e_per_usd`     | Supply chain emission factor             |
| `mef_kgco2e_per_usd`     | Margin emission factor                   |
| `sef_mef_kgco2e_per_usd` | Combined SEF and MEF                     |
| `sum_check_diff`         | Difference/check between emission values |
| `reference_year`         | Reference year for the data              |
| `intensity_tier`         | Carbon-intensity classification          |

The table uses `naics_code` as the primary key and includes an index on `intensity_tier`.

---

### 2. `emission_factors_by_gas`

This table contains emission-factor information broken down by individual greenhouse gases.

| Column                  | Description                         |
| ----------------------- | ----------------------------------- |
| `id`                    | Unique record identifier            |
| `naics_code`            | NAICS industry/commodity code       |
| `naics_title`           | Industry or commodity name          |
| `useeio_code`           | USEEIO code                         |
| `gas`                   | Greenhouse gas                      |
| `unit_type`             | Measurement unit                    |
| `sef_value_per_usd`     | Supply chain emission factor by gas |
| `mef_value_per_usd`     | Margin emission factor by gas       |
| `sef_mef_value_per_usd` | Combined emission factor            |
| `reference_year`        | Reference year                      |

A unique constraint is applied to `(naics_code, gas)` and an index is created on `naics_code`.

---

# 📊 Analysis Performed

## 1. Total Number of Commodities

The project begins by determining the total number of commodities available in the dataset.

```sql
SELECT COUNT(*) AS total_commodities
FROM emission_factors_co2e;
```

---

## 2. View the First 10 Commodities

The first 10 records are reviewed to understand the structure and contents of the dataset.

```sql
SELECT *
FROM emission_factors_co2e
LIMIT 10;
```

---

## 3. Highest Carbon-Intensity Commodities

The analysis identifies commodities with the highest combined carbon intensity.

```sql
SELECT
    naics_code,
    naics_title,
    sef_mef_kgco2e_per_usd
FROM emission_factors_co2e
ORDER BY sef_mef_kgco2e_per_usd DESC
LIMIT 10;
```

This helps identify industries with relatively high emissions per dollar of economic activity.

---

## 4. Lowest Carbon-Intensity Commodities

The analysis also identifies commodities with the lowest combined carbon intensity.

```sql
SELECT
    naics_code,
    naics_title,
    sef_mef_kgco2e_per_usd
FROM emission_factors_co2e
ORDER BY sef_mef_kgco2e_per_usd ASC
LIMIT 10;
```

---

## 5. Commodity-Level Analysis

Specific commodities can be investigated using their NAICS code.

For example:

```sql
SELECT *
FROM emission_factors_co2e
WHERE naics_code = '327310';
```

This allows individual commodities to be examined in greater detail.

---

## 6. High Carbon-Intensity Commodities

The project filters commodities where combined carbon intensity exceeds a selected threshold.

```sql
SELECT
    naics_code,
    naics_title,
    sef_mef_kgco2e_per_usd
FROM emission_factors_co2e
WHERE sef_mef_kgco2e_per_usd > 1
ORDER BY sef_mef_kgco2e_per_usd DESC;
```

---

# 📈 Intensity Tier Analysis

The dataset contains an `intensity_tier` classification that can be used to compare groups of commodities.

## High and Very High Intensity

```sql
SELECT
    naics_code,
    naics_title,
    sef_mef_kgco2e_per_usd,
    intensity_tier
FROM emission_factors_co2e
WHERE intensity_tier IN ('High', 'Very High')
ORDER BY sef_mef_kgco2e_per_usd DESC;
```

---

## Number of Commodities by Intensity Tier

```sql
SELECT
    intensity_tier,
    COUNT(*) AS commodity_count
FROM emission_factors_co2e
GROUP BY intensity_tier
ORDER BY commodity_count DESC;
```

This provides an overview of how commodities are distributed across the different carbon-intensity classifications.

---

## Average Carbon Intensity by Tier

```sql
SELECT
    intensity_tier,
    ROUND(AVG(sef_mef_kgco2e_per_usd), 4) AS average_intensity
FROM emission_factors_co2e
GROUP BY intensity_tier
ORDER BY average_intensity DESC;
```

---

# 🔬 SEF vs MEF Analysis

The project compares:

* **SEF** — Supply Chain Emission Factor
* **MEF** — Margin Emission Factor
* **SEF + MEF** — Combined emission factor

## Percentage Share of SEF and MEF

The analysis calculates the relative contribution of SEF and MEF to the combined carbon intensity.

```sql
SELECT
    naics_code,
    naics_title,
    sef_kgco2e_per_usd,
    mef_kgco2e_per_usd,
    sef_mef_kgco2e_per_usd,
    ROUND(
        sef_kgco2e_per_usd / sef_mef_kgco2e_per_usd * 100,
        2
    ) AS sef_percentage,
    ROUND(
        mef_kgco2e_per_usd / sef_mef_kgco2e_per_usd * 100,
        2
    ) AS mef_percentage
FROM emission_factors_co2e;
```

---

## Commodities Where MEF Is Greater Than SEF

```sql
SELECT
    naics_code,
    naics_title,
    sef_kgco2e_per_usd,
    mef_kgco2e_per_usd
FROM emission_factors_co2e
WHERE mef_kgco2e_per_usd > sef_kgco2e_per_usd
ORDER BY mef_kgco2e_per_usd DESC;
```

This identifies commodities where the margin emission factor is larger than the supply-chain emission factor.

---

## Largest Difference Between SEF and MEF

The project also calculates the absolute difference between the two factors.

```sql
SELECT
    naics_code,
    naics_title,
    sef_kgco2e_per_usd,
    mef_kgco2e_per_usd,
    ABS(sef_kgco2e_per_usd - mef_kgco2e_per_usd) AS absolute_difference
FROM emission_factors_co2e
ORDER BY absolute_difference DESC
LIMIT 10;
```

---

# 🌍 Greenhouse Gas Analysis

The second table allows emissions to be analyzed by individual greenhouse gas.

## Number of Records by Gas

```sql
SELECT
    gas,
    COUNT(*) AS gas_count
FROM emission_factors_by_gas
GROUP BY gas
ORDER BY gas_count DESC;
```

---

## Average SEF by Greenhouse Gas

```sql
SELECT
    gas,
    ROUND(AVG(sef_value_per_usd), 6) AS average_sef
FROM emission_factors_by_gas
GROUP BY gas
ORDER BY average_sef DESC;
```

This allows the contribution of different greenhouse gases to be examined separately.

---

# 🔗 SQL JOIN Analysis

The project joins the commodity-level table with the greenhouse-gas-level table using the NAICS code.

```sql
SELECT
    c.naics_code,
    c.naics_title,
    c.sef_mef_kgco2e_per_usd,
    g.gas,
    g.sef_value_per_usd
FROM emission_factors_co2e AS c
JOIN emission_factors_by_gas AS g
    ON c.naics_code = g.naics_code;
```

This combines information from both tables and makes it possible to analyze commodity-level emissions alongside individual gases.

---

# 📊 Total Gas-Level SEF by Commodity

The project aggregates gas-level supply-chain emission factors for each commodity.

```sql
SELECT
    naics_code,
    naics_title,
    SUM(sef_value_per_usd) AS total_gas_sef
FROM emission_factors_by_gas
GROUP BY
    naics_code,
    naics_title
ORDER BY total_gas_sef DESC;
```

---

# 📌 Commodities Above the Overall Average

A subquery is used to calculate the overall average carbon intensity and identify commodities above that average.

```sql
SELECT
    naics_code,
    naics_title,
    sef_mef_kgco2e_per_usd
FROM emission_factors_co2e
WHERE sef_mef_kgco2e_per_usd >
      (
          SELECT AVG(sef_mef_kgco2e_per_usd)
          FROM emission_factors_co2e
      )
ORDER BY sef_mef_kgco2e_per_usd DESC;
```

This demonstrates how subqueries can be used for comparative analysis.

---

# 🏆 Window Function Analysis

The project also demonstrates more advanced SQL techniques using window functions.

## Percent Rank

`PERCENT_RANK()` is used to determine the relative position of commodities based on carbon intensity.

```sql
SELECT
    naics_code,
    naics_title,
    sef_mef_kgco2e_per_usd,
    PERCENT_RANK() OVER (
        ORDER BY sef_mef_kgco2e_per_usd
    ) AS percent_rank
FROM emission_factors_co2e;
```

---

## Commodity Ranking

`RANK()` is used to rank commodities based on their carbon intensity.

```sql
SELECT
    naics_code,
    naics_title,
    sef_mef_kgco2e_per_usd,
    RANK() OVER (
        ORDER BY sef_mef_kgco2e_per_usd DESC
    ) AS emission_rank
FROM emission_factors_co2e;
```

---

## Percentage of Total Carbon Intensity

A windowed `SUM()` is used to calculate each commodity's percentage contribution relative to the total.

```sql
SELECT
    naics_code,
    naics_title,
    sef_mef_kgco2e_per_usd,
    ROUND(
        sef_mef_kgco2e_per_usd /
        SUM(sef_mef_kgco2e_per_usd) OVER () * 100,
        2
    ) AS percentage_of_total
FROM emission_factors_co2e
ORDER BY percentage_of_total DESC;
```

---

# 🛠️ SQL Skills Demonstrated

This project demonstrates the following SQL skills:

### Database Management

* `CREATE DATABASE`
* `USE`
* `CREATE TABLE`
* `ALTER TABLE`
* `DROP TABLE`
* Primary keys
* Unique constraints
* Indexes

### Data Retrieval

* `SELECT`
* `WHERE`
* `ORDER BY`
* `LIMIT`

### Data Aggregation

* `COUNT()`
* `SUM()`
* `AVG()`
* `MIN()`
* `MAX()`

### Data Transformation

* `ROUND()`
* `ABS()`
* Percentage calculations
* Conditional filtering
* Carbon-intensity classification

### Advanced SQL

* `JOIN`
* Subqueries
* `GROUP BY`
* `HAVING`
* Window functions
* `RANK()`
* `PERCENT_RANK()`
* `SUM() OVER()`

---

# 📁 Project Structure

```text
supply-chain-ghg-emissions-sql/
│
├── README.md
│
├── supply_chain_ghg.sql
│
└── data/
    └── emission_factors_data.csv
```

> The exact filenames and folder structure may vary depending on how the project is organized in the repository.

---

# 💻 How to Run the Project

## 1. Install MySQL

Install **MySQL Server** and **MySQL Workbench**.

## 2. Create the Database

Run:

```sql
CREATE DATABASE IF NOT EXISTS supply_chain_ghg;

USE supply_chain_ghg;
```

## 3. Create the Tables

Run the table creation statements from the SQL file.

## 4. Import the Data

Import the emission-factor datasets into their corresponding tables.

## 5. Run the Analysis

Execute the analytical queries included in the SQL file.

You can modify the queries to investigate different commodities, greenhouse gases, and carbon-intensity categories.

---

# ❓ Key Analytical Questions

This project uses SQL to answer questions such as:

* How many commodities are included in the dataset?
* Which commodities have the highest carbon intensity?
* Which commodities have the lowest carbon intensity?
* Which commodities have a combined carbon intensity greater than 1?
* How are commodities distributed across intensity tiers?
* What is the average carbon intensity for each tier?
* Which commodities have a higher MEF than SEF?
* Which commodities have the largest difference between SEF and MEF?
* Which greenhouse gases appear in the dataset?
* What is the average SEF for each greenhouse gas?
* How do individual greenhouse gases contribute to commodity emissions?
* Which commodities have carbon intensity above the overall average?
* How do commodities rank based on carbon intensity?
* What percentage of total carbon intensity is associated with each commodity?

---

# 🌱 Project Value

Understanding greenhouse gas emission factors can help organizations analyze the environmental impact associated with economic activity and supply chains.

This project demonstrates how SQL can be used to transform raw emission-factor data into structured analysis through:

**Data → SQL Queries → Aggregation → Comparison → Rankings → Insights**

The project is primarily designed to demonstrate **SQL and data-analysis skills** using an environmental dataset.

---

# 🧰 Tools & Technologies

* **MySQL**
* **MySQL Workbench**
* **SQL**
* Relational Database Design
* Data Analysis
* Window Functions

---

# 📚 Concepts Demonstrated

* Relational databases
* Data modeling
* Primary keys
* Unique constraints
* Database indexes
* Data aggregation
* Filtering
* Sorting
* Grouping
* Joins
* Subqueries
* Window functions
* Ranking
* Percentage calculations
* Environmental data analysis
* Supply-chain emissions analysis

---

# ⚠️ Disclaimer

This project is intended for **educational and analytical purposes**. The SQL analysis demonstrates techniques for working with greenhouse gas emission-factor data and should not be interpreted as an independent environmental assessment.

---

# 👤 Author

**Netlution**

Data Analytics | SQL | MySQL | Data Analysis

---

# ⭐ If You Find This Project Useful

Feel free to **star the repository** and explore the SQL queries to see how relational data and advanced SQL techniques can be used to analyze supply-chain greenhouse gas emissions.
