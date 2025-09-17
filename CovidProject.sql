---I worked on SQL data exploration using a COVID-19 dataset. 
--I walked through downloading, cleaning, and preparing the data, 
--then wrote queries to analyze cases, deaths, vaccination progress, and global statistics.

SELECT * 
FROM CovidDeaths
WHERE continent is not NULL

--Select data that I going to use

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM CovidDeaths
WHERE continent is not NULL
order by 1,2

--Total deaths\total cases

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS  Percentage
FROM CovidDeaths
Where location = 'Kazakhstan'
order by 1,2

--Shows what percentage of population got covid

SELECT location, date, population, total_cases,  (total_cases/population)*100 AS  Percentage
FROM CovidDeaths
Where location = 'Kazakhstan'
order by 1,2

--Loking at  Countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfCount,  MAX((total_cases/population)) * 100 AS  Percentage
FROM CovidDeaths
--Where location = 'Kazakhstan' AND continent is not NULL
GROUP BY location, population
order by  4 DESC

--Showing Countries with Highest Deaths count per population 
--(total_deaths incorrect data type)

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathsCount
FROM CovidDeaths
WHERE continent is not NULL
GROUP BY location
Order by  TotalDeathsCount desc 

-- Total population and total vaccination------------

SELECT dea.location, dea.date,   vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingCountVac
FROM CovidDeaths dea
					JOIN CovidVaccination vac
					ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

--CTE-------------------------

with PopVac (location, date, new_vaccination, RollingCountVac)
as
(
SELECT dea.location, dea.date,   vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingCountVac
FROM CovidDeaths dea
					JOIN CovidVaccination vac
					ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
AND dea.date >= '2021-01-01'
)

SELECT *
FROM PopVac

--Creating View to storage data for later visualizations

Create View RollingCountVac AS
SELECT dea.location, dea.date,   vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingCountVac
FROM CovidDeaths dea
					JOIN CovidVaccination vac
					ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

AND dea.date >= '2021-01-01'

