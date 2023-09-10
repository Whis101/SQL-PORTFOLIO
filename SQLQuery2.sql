



-- Select Data to be used
SELECT *
FROM PortfolioProject..CovidDeath
WHERE continent is not null
ORDER BY 3,4;

SELECT *
FROM PortfolioProject..CovidVaccinations
WHERE continent is not null
ORDER BY 3,4;

--Basic Information Retrieval:

-- TOTAL CASES VS TOTAL DEATHS FOR USA
SELECT location,date, total_cases, total_deaths, 100*CAST(total_deaths AS FLOAT)/CAST(total_cases AS FLOAT) as deathpercentage
FROM PortfolioProject..CovidDeath
WHERE location like '%states%' AND continent is not null
ORDER BY 1,2;
----CREATING VIEW FOR TOTAL CASES VS TOTAL DEATHS
USE PortfolioProject
GO
CREATE VIEW USA_TOTAL_CASES_VS_TOTAL_DEATHS as
SELECT location,date, total_cases, total_deaths, 100*CAST(total_deaths AS FLOAT)/CAST(total_cases AS FLOAT) as deathpercentage
FROM PortfolioProject..CovidDeath
WHERE location like '%states%' AND continent is not null


--LOOKING AT TOTAL CASES VS POPULATION
SELECT coviddeath.date,coviddeath.location, PortfolioProject..CovidDeath.total_cases
,PortfolioProject..CovidVaccinations.population
,CONCAT(ROUND(100*(CAST(PortfolioProject..CovidDeath.total_cases AS FLOAT)/PortfolioProject..CovidVaccinations.population),2),'%') AS Percent_of_Population_With_Covid
FROM PortfolioProject..CovidDeath 
INNER JOIN PortfolioProject..CovidVaccinations 
ON PortfolioProject..CovidDeath.iso_code = PortfolioProject..CovidVaccinations.iso_code
WHERE coviddeath.continent is not null;

--CREATING VIEW FOR TOTAL CASES VS POPULATION
USE PortfolioProject
GO
CREATE VIEW total_cases_vs_population as
SELECT coviddeath.date,coviddeath.location, PortfolioProject..CovidDeath.total_cases
,PortfolioProject..CovidVaccinations.population
,CONCAT(ROUND(100*(CAST(PortfolioProject..CovidDeath.total_cases AS FLOAT)/PortfolioProject..CovidVaccinations.population),2),'%') AS Percent_of_Population_With_Covid
FROM PortfolioProject..CovidDeath 
INNER JOIN PortfolioProject..CovidVaccinations 
ON PortfolioProject..CovidDeath.iso_code = PortfolioProject..CovidVaccinations.iso_code
WHERE coviddeath.continent is not null

--LOOKING AT Countries with Highest Infection Rate compared to Population.
SELECT PortfolioProject..CovidDeath.location
,PortfolioProject..CovidVaccinations.population ,MAX(PortfolioProject..CovidDeath.total_cases) as HighestInfectionCount,
MAX((CAST(PortfolioProject..CovidDeath.total_cases AS FLOAT)/PortfolioProject..CovidVaccinations.population))*100  AS HIGHEST_INFECTION_RATE
FROM PortfolioProject..CovidDeath 
INNER JOIN PortfolioProject..CovidVaccinations 
ON PortfolioProject..CovidDeath.iso_code = PortfolioProject..CovidVaccinations.iso_code
WHERE coviddeath.continent is not null
GROUP BY PortfolioProject..CovidDeath.location,PortfolioProject..CovidVaccinations.population
ORDER BY 1 DESC;

--CREATE VIEW FOR Highest Infection Rate
USE PortfolioProject
GO
CREATE VIEW highest_infection_rate as
SELECT PortfolioProject..CovidDeath.location
,PortfolioProject..CovidVaccinations.population ,MAX(PortfolioProject..CovidDeath.total_cases) as HighestInfectionCount,
MAX((CAST(PortfolioProject..CovidDeath.total_cases AS FLOAT)/PortfolioProject..CovidVaccinations.population))*100  AS HIGHEST_INFECTION_RATE
FROM PortfolioProject..CovidDeath 
INNER JOIN PortfolioProject..CovidVaccinations 
ON PortfolioProject..CovidDeath.iso_code = PortfolioProject..CovidVaccinations.iso_code
WHERE coviddeath.continent is not null
GROUP BY PortfolioProject..CovidDeath.location,PortfolioProject..CovidVaccinations.population





--Lets break things down by continent
SELECT cd.continent, Max(CAST(cd.Total_deaths AS int)) as TotalDeathCount
FROM PortfolioProject..CovidDeath cd
WHERE continent is not null
GROUP BY cd.continent
order by TotalDeathCount desc;
--CREATE VIEW DEATHS PER CONTINENTS
USE PortfolioProject
GO
CREATE VIEW deaths_per_continents AS
SELECT cd.continent, Max(CAST(cd.Total_deaths AS int)) as TotalDeathCount
FROM PortfolioProject..CovidDeath cd
WHERE continent is not null
GROUP BY cd.continent







--Global Numbers
SELECT date, SUM(new_cases) as daily_global_cases, SUM(new_deaths) as daily_global_deaths,ROUND(100*sum(new_deaths)/NULLIF(sum(new_cases),0),2) as daily_mortality
FROM PortfolioProject..CovidDeath
WHERE continent is not null
GROUP BY date
ORDER BY 1,2;

USE PortfolioProject
GO
CREATE VIEW Global_numbers AS 
SELECT date, SUM(new_cases) as daily_global_cases, SUM(new_deaths) as daily_global_deaths,ROUND(100*sum(new_deaths)/NULLIF(sum(new_cases),0),2) as daily_mortality
FROM PortfolioProject..CovidDeath
WHERE continent is not null
GROUP BY date

--LOOKING AT TOTAL VACCINATION VS POPULATION


-- USE CTE
WITH popvsvac (Continent, Location, Date, Population,new_vaccinations, rolling_people_vaccinated)
AS
(
SELECT cd.continent,cd.location,cd.date,cv.population
,cv.new_vaccinations,SUM(CAST(new_vaccinations AS BIGINT)) OVER(PARTITION BY cv.location ORDER BY cd.date,cd.location) as rolling_people_vaccinated
FROM PortfolioProject..CovidDeath cd
INNER JOIN PortfolioProject..CovidVaccinations cv
ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *,100*(rolling_people_vaccinated/Population)
FROM popvsvac




--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar (255)
,Location nvarchar (255)
,Date datetime
,Population numeric
,New_vaccinations numeric
,RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT cd.continent,cd.location,cd.date,cv.population
,cv.new_vaccinations,SUM(CAST(new_vaccinations AS BIGINT)) OVER(PARTITION BY cv.location ORDER BY cd.date,cd.location) as rolling_people_vaccinated
FROM PortfolioProject..CovidDeath cd
INNER JOIN PortfolioProject..CovidVaccinations cv
ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
--ORDER BY 2,3

SELECT *,100*(rollingpeoplevaccinated/Population)
FROM #PercentPopulationVaccinated





--STORING DATA FOR LATER VISUALISATION
DROP VIEW if exists PercentPopulationVaccinated
USE PortfolioProject
GO
CREATE VIEW PercentPopulationVaccinated as
SELECT cd.continent,cd.location,cd.date,cv.population
,cv.new_vaccinations,SUM(CAST(new_vaccinations AS BIGINT)) OVER(PARTITION BY cv.location ORDER BY cd.date,cd.location) as rolling_people_vaccinated
FROM PortfolioProject..CovidDeath cd
INNER JOIN PortfolioProject..CovidVaccinations cv
ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
--ORDER BY 2,3
SELECT *
FROM DBO.PercentPopulationVaccinated
--Showing Countries with the Highest Death Per Population

SELECT cd.Location, Max(CAST(cd.Total_deaths AS int)) as TotalDeathCount
FROM PortfolioProject..CovidDeath cd
WHERE continent is not null 
GROUP BY cd.location
order by TotalDeathCount desc;

--Retrieve the total number of COVID-19 cases.

WITH cases AS (SELECT location, SUM(CAST (CD.new_cases AS bigint)) as total_cases
FROM PortfolioProject..CovidDeath CD
GROUP BY location)

SELECT FORMAT(sum(CAST(total_cases AS bigint)),'N2') AS GLOBAL_CASES
FROM cases;
--Get the total number of deaths reported.
WITH deaths AS (SELECT location, SUM(CAST (CD.new_deaths AS bigint)) as total_deaths
FROM PortfolioProject..CovidDeath CD
GROUP BY location)

SELECT FORMAT(sum(CAST(total_deaths AS bigint)),'N2') AS GLOBAL_deaths
FROM deaths;



--Retrieve the daily new cases, deaths
SELECT date,new_cases, new_deaths
FROM PortfolioProject..CovidDeath;
--Calculate the daily percentage change in cases.
WITH prev_case AS (SELECT LAG(new_cases) OVER(ORDER BY date) as previous_cases,new_cases
from PortfolioProject..CovidDeath)

SELECT previous_cases,new_cases,CASE
WHEN previous_cases=0 THEN NULL ELSE CONCAT(ROUND(100*new_cases/previous_cases,0),'%') END as percentage_change
FROM prev_case;
--Geographical Analysis:

--Retrieve COVID-19 statistics for a specific country or region.
--Find the top 5 countries with the highest number of cases.
SELECT  location,FORMAT(sum(new_cases),'N2') as case_sum
FROM PortfolioProject..CovidDeath
GROUP BY location
ORDER BY case_sum DESC
OFFSET 1 ROWS
FETCH NEXT 5 ROWS ONLY;
--Time Series Analysis:

--Find the date with the highest number of reported cases.
SELECT TOP 1 date,MAX(new_cases) as highest_day
from PortfolioProject..CovidDeath
GROUP BY DATE;

--Compare the COVID-19 statistics between two or more countries.
--Find the country with the highest death rate per capita.
SELECT TOP 5 location,AVG(CAST(total_deaths_per_million AS float))
FROM PortfolioProject..CovidDeath
GROUP BY location
;

--Vaccination Data:

--Retrieve information about the number of vaccine doses administered.
SELECT total_vaccinations
FROM PortfolioProject..CovidVaccinations;
--Find the percentage of the population that has been vaccinated.

--Severity Analysis:

--Calculate the case fatality rate (CFR) for a specific country.
--Find the country with the highest CFR.
--Trends and Patterns:

--Identify any noticeable trends or patterns in the data (e.g., spikes, plateaus, etc.).
--Analyze if there are any seasonal trends in the data.
--Age Group Analysis:

--Retrieve COVID-19 statistics based on different age groups.
--Calculate the mortality rate by age group.
--Hospitalization and ICU Data:

--Retrieve information about hospitalizations and ICU admissions.
--Calculate the percentage of COVID-19 patients requiring intensive care.

SELECT TOP 1 location,date,total_cases,new_cases,total_deaths,population_density
FROM PortfolioProject..CovidDeaths
WHERE location = 'Afghanistan'
AND total_deaths=1
ORDER BY date;

ALTER TABLE dbo.CovidDeath
ALTER COLUMN total_deaths int;

EXEC sp_help 'dbo.CovidDeaths';

