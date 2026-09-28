CREATE DATABASE IF NOT EXISTS supply_chain_ghg;

USE supply_chain_ghg;

DROP TABLE IF EXISTS emission_factors_co2e;

CREATE TABLE emission_factors_co2e (
    naics_code             CHAR(6)        NOT NULL,
    naics_title            VARCHAR(255)   NOT NULL,
    useeio_code            VARCHAR(10),
    sef_kgco2e_per_usd     DECIMAL(18,9)  NOT NULL,
    mef_kgco2e_per_usd     DECIMAL(18,9)  NOT NULL,
    sef_mef_kgco2e_per_usd DECIMAL(18,9)  NOT NULL,
    sum_check_diff         DECIMAL(18,9),
    reference_year         SMALLINT       NOT NULL DEFAULT 2022,
    intensity_tier         VARCHAR(30)    NOT NULL,
    PRIMARY KEY (naics_code),
    INDEX idx_intensity_tier (intensity_tier)
);

USE supply_chain_ghg;

ALTER TABLE emission_factors_co2e
MODIFY COLUMN useeio_code VARCHAR(255);

SELECT COUNT(*) AS total_records
FROM emission_factors_co2e;

CREATE TABLE emission_factors_by_gas (
    id                        BIGINT AUTO_INCREMENT PRIMARY KEY,
    naics_code                CHAR(6)        NOT NULL,
    naics_title               VARCHAR(255)   NOT NULL,
    useeio_code               VARCHAR(255),
    gas                       VARCHAR(50)    NOT NULL,
    unit_type                 ENUM('kg_gas_per_usd','kg_CO2e_per_usd') NOT NULL,
    sef_value_per_usd         DECIMAL(20,12) NOT NULL,
    mef_value_per_usd         DECIMAL(20,12) NOT NULL,
    sef_mef_value_per_usd     DECIMAL(20,12) NOT NULL,
    reference_year            SMALLINT       NOT NULL DEFAULT 2022,

    UNIQUE KEY uq_naics_gas (naics_code, gas),
    INDEX idx_naics_code (naics_code)
);

SELECT count(*) as Totalrecord
FROM emission_factors_by_gas;

SELECT
    e.naics_code,
    e.naics_title,
    e.sef_kgco2e_per_usd,
    e.mef_kgco2e_per_usd,
    g.gas,
    g.sef_value_per_usd,
    g.mef_value_per_usd
FROM emission_factors_co2e AS e
JOIN emission_factors_by_gas AS g
    ON e.naics_code = g.naics_code;

# How many commodities are in the EPA dataset?

SELECT COUNT(*) AS TOTAL_COMMODITIES
FROM emission_factors_co2e;

# What are the first 10 commodities in the dataset?

SELECT
    naics_code,
    naics_title
FROM emission_factors_co2e
LIMIT 10;


-- Which commodities cost the most carbon per dollar spent?
SELECT
    naics_code,
    naics_title,
    sef_mef_kgco2e_per_usd
FROM emission_factors_co2e
ORDER BY sef_mef_kgco2e_per_usd DESC
LIMIT 10;

# Which commodities cost the least carbon per dollar spent?

SELECT
    naics_code,
    naics_title,
    sef_mef_kgco2e_per_usd
FROM emission_factors_co2e
ORDER BY sef_mef_kgco2e_per_usd ASC
LIMIT 10;

# What is the carbon intensity of a specific commodity?
SELECT
    naics_code,
    naics_title,
    sef_kgco2e_per_usd,
    mef_kgco2e_per_usd,
    sef_mef_kgco2e_per_usd
FROM emission_factors_co2e
WHERE naics_code = '327310';

# Which commodities have carbon intensity above 1 kg CO₂e per USD?

SELECT
    naics_code,
    naics_title,
    sef_mef_kgco2e_per_usd
FROM emission_factors_co2e
WHERE sef_mef_kgco2e_per_usd > 1
ORDER BY sef_mef_kgco2e_per_usd DESC;

# Which commodities are classified as High or Very High intensity?
SELECT
    naics_code,
    naics_title,
    intensity_tier,
    sef_mef_kgco2e_per_usd
FROM emission_factors_co2e
WHERE intensity_tier IN ('High', 'Very High')
ORDER BY sef_mef_kgco2e_per_usd DESC;

# What percentage of each commodity's footprint comes from SEF versus MEF?

SELECT
    naics_code,
    naics_title,
    sef_kgco2e_per_usd,
    mef_kgco2e_per_usd,
    sef_mef_kgco2e_per_usd,

    ROUND(
        (sef_kgco2e_per_usd / sef_mef_kgco2e_per_usd) * 100,
        2
    ) AS sef_share_percent,

    ROUND(
        (mef_kgco2e_per_usd / sef_mef_kgco2e_per_usd) * 100,
        2
    ) AS mef_share_percent

FROM emission_factors_co2e;

# Where do margins/logistics emissions outweigh production emissions?

SELECT
    naics_code,
    naics_title,
    sef_kgco2e_per_usd,
    mef_kgco2e_per_usd,
    sef_mef_kgco2e_per_usd
FROM emission_factors_co2e
WHERE mef_kgco2e_per_usd > sef_kgco2e_per_usd
ORDER BY mef_kgco2e_per_usd DESC;

# Which commodities have the largest difference between SEF and MEF?
SELECT
    naics_code,
    naics_title,
    sef_kgco2e_per_usd,
    mef_kgco2e_per_usd,

    ROUND(
        ABS(sef_kgco2e_per_usd - mef_kgco2e_per_usd),
        4
    ) AS sef_mef_difference

FROM emission_factors_co2e
ORDER BY sef_mef_difference DESC
LIMIT 10;

# How many commodities are in each intensity tier?
SELECT
    intensity_tier,
    COUNT(*) AS commodity_count
FROM emission_factors_co2e
GROUP BY intensity_tier
ORDER BY commodity_count DESC;

# What is the average carbon intensity for each intensity tier?
SELECT
     intensity_tier,
     count(*) as commodity_count,
     ROUND(
        AVG(sef_mef_kgco2e_per_usd),
        4
        ) AS average_intensity
FROM emission_factors_co2e
GROUP BY intensity_tier
ORDER BY average_intensity DESC;

# What are the minimum, average, and maximum carbon intensities?
SELECT
    MIN(sef_mef_kgco2e_per_usd) AS minimum_intensity,
    ROUND(AVG(sef_mef_kgco2e_per_usd), 4) AS average_intensity,
    MAX(sef_mef_kgco2e_per_usd) AS maximum_intensity
FROM emission_factors_co2e;

# Which intensity tier has the highest average carbon intensity?

SELECT
    intensity_tier,
    ROUND(
        AVG(sef_mef_kgco2e_per_usd),
        4
    ) AS average_intensity
FROM emission_factors_co2e
GROUP BY intensity_tier
ORDER BY average_intensity DESC
LIMIT 1;
	
# How many records are there for each greenhouse gas?

SELECT
    gas,
    COUNT(*) AS record_count
FROM emission_factors_by_gas
GROUP BY gas
ORDER BY record_count DESC;

# How many records are there for each greenhouse gas?
SELECT
    gas,
    COUNT(*) AS record_count
FROM emission_factors_by_gas
GROUP BY gas
ORDER BY record_count DESC;

# Which greenhouse gas has the highest average emission per dollar?

SELECT
    gas,
    ROUND(
        AVG(sef_value_per_usd),
        6
    ) AS average_sef_per_usd
FROM emission_factors_by_gas
WHERE unit_type = 'kg_gas_per_usd'
GROUP BY gas
ORDER BY average_sef_per_usd DESC;

# What is the complete gas breakdown for a specific commodity?

SELECT
    naics_code,
    naics_title,
    gas,
    unit_type,
    sef_value_per_usd,
    mef_value_per_usd,
    sef_mef_value_per_usd
FROM emission_factors_by_gas
WHERE naics_code = '327310'
ORDER BY sef_mef_value_per_usd DESC;

# How do the commodity-level factors relate to the gas-level

SELECT
    e.naics_code,
    e.naics_title,
    e.sef_mef_kgco2e_per_usd,
    e.intensity_tier,
    g.gas,
    g.unit_type,
    g.sef_value_per_usd,
    g.mef_value_per_usd,
    g.sef_mef_value_per_usd
FROM emission_factors_co2e AS e
JOIN emission_factors_by_gas AS g
    ON e.naics_code = g.naics_code
ORDER BY e.naics_code, g.gas;

# Which commodities have the highest total gas-level SEF values?

SELECT
    e.naics_code,
    e.naics_title,
    ROUND(
        SUM(g.sef_value_per_usd),
        6
    ) AS total_gas_sef
FROM emission_factors_co2e AS e
JOIN emission_factors_by_gas AS g
    ON e.naics_code = g.naics_code
WHERE g.unit_type = 'kg_gas_per_usd'
GROUP BY
    e.naics_code,
    e.naics_title
ORDER BY total_gas_sef DESC
LIMIT 10;

# Which commodities have carbon intensity above the overall average?
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

# Which commodities are in the top 10% of carbon intensity?
SELECT
    naics_code,
    naics_title,
    sef_mef_kgco2e_per_usd,
    ROUND(
        PERCENT_RANK() OVER (
            ORDER BY sef_mef_kgco2e_per_usd
        ),
        4
    ) AS percentile_rank
FROM emission_factors_co2e
ORDER BY sef_mef_kgco2e_per_usd DESC;

# How do all commodities rank from highest to lowest carbon intensity?
SELECT
    RANK() OVER (
        ORDER BY sef_mef_kgco2e_per_usd DESC
    ) AS carbon_rank,
    naics_code,
    naics_title,
    sef_mef_kgco2e_per_usd
FROM emission_factors_co2e
ORDER BY carbon_rank;

# What percentage of the total intensity is represented by each commodity?

SELECT
    naics_code,
    naics_title,
    sef_mef_kgco2e_per_usd,

    ROUND(
        (
            sef_mef_kgco2e_per_usd /
            SUM(sef_mef_kgco2e_per_usd) OVER ()
        ) * 100,
        4
    ) AS percentage_of_total

FROM emission_factors_co2e
ORDER BY sef_mef_kgco2e_per_usd DESC;