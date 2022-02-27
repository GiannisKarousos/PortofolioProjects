SELECT *
FROM PortofolioProject..CovidDeaths
ORDER BY 3,4

--Second table
--SELECT *
--FROM PortofolioProject..CovidDeaths
--ORDER BY 3,4

--Select data for use

SELECT location, date, total_cases, new_cases, total_deaths,population
FROM PortofolioProject..CovidDeaths
ORDER BY 1,2 --order by location and then date

--Checking on Total Cases vs Total Deaths
--Creating a new col - shows the likelihood of dying if you get covid
--Checking for GR (1.1%)

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPerc
FROM PortofolioProject..CovidDeaths
WHERE location LIKE '%Greec%'
ORDER BY 1,2 

--Checking on Total Cases vs Population
--Checking the % of population caught covid (23%) in GR

SELECT location, date, total_cases, population, (total_cases/population)*100 AS InfectedPerc
FROM PortofolioProject..CovidDeaths
WHERE location LIKE '%Greec%'
ORDER BY 1,2

--Checkning on countries with highest infected%

SELECT location, population, MAX(total_cases) AS HighestNumCases, MAX((total_cases/population))*100 AS InfectedPerc
FROM PortofolioProject..CovidDeaths
GROUP BY location, population
ORDER BY InfectedPerc DESC

--Showing countries with highest #death
--Taking out null continent to exclude them from location
--Casting Total Deaths as integer

SELECT location, MAX(CAST(Total_Deaths AS int)) AS DeathNum
FROM PortofolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY DeathNum DESC

--Showing CONTINENTS with highest #death
--careful with the where (i didn't use continent col)

SELECT location, MAX(CAST(Total_Deaths AS int)) AS DeathNum
FROM PortofolioProject..CovidDeaths
WHERE continent IS  NULL AND location NOT IN ('Upper middle income', 'High income','Lower middle income','Low income')
GROUP BY location
ORDER BY DeathNum DESC

-- GLOBAL NUMBERS (1,36% deathperc)

SELECT SUM(new_cases) AS totalcases, SUM(CAST(new_deaths AS int)) AS totaldeaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPerc
FROM PortofolioProject..CovidDeaths
WHERE continent is not NULL
--GROUP BY date
ORDER BY 1,2 

--JOINING Tables (CovidDeath and CovidVac)

SELECT *
FROM PortofolioProject..CovidDeaths dea
INNER JOIN PortofolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date

--Looking at Total Population vs Vaccinations
--Cumulative on new_vac per location
--USING CTE (common tale expresion) (Must have same num of collumns in with and select)

With PopvsVac (Continent, location, date, population, new_vaccinations, CumulativeVacs)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS int)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CumulativeVacs
--,(CumulativeVacs/population)*100
FROM PortofolioProject..CovidDeaths dea
INNER JOIN PortofolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT*, (CumulativeVacs/population)*100 AS VacsPerc
FROM PopvsVac

--TEMP TABLE

DROB TABLE IF exists #PercentPopVacs
CREATE TABLE #PercentPopVacs
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
CumulativeVacs numeric
)
INSERT INTO #PercentPopVacs
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS int)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CumulativeVacs
--,(CumulativeVacs/population)*100
FROM PortofolioProject..CovidDeaths dea
INNER JOIN PortofolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT*, (CumulativeVacs/population)*100 AS VacsPerc
FROM #PercentPopVacs

--Creating View to store data for later visualizations

CREATE VIEW PercentPopVacs AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS int)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CumulativeVacs
--,(CumulativeVacs/population)*100
FROM PortofolioProject..CovidDeaths dea
INNER JOIN PortofolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopVacs