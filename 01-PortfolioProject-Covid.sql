--SELECT *
--FROM PortfolioProject..CovidDeaths
--WHERE continent is not null
--ORDER BY 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4

-- Select the Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows de likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, 
(total_deaths / total_cases) * 100 as mortality_rate_pers
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
and continent is not null
ORDER BY 1, 2

-- Looking Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT location, date, total_cases, population,
(total_cases / population) * 100 AS infection_rate
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY location, date

-- Looking at Countries with Highest Infection Rate

SELECT location,  population, max(total_cases) AS highest_infection_count, MAX((total_cases / population) * 100) AS max_infect_rate
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY 4 DESC

-- Showing Countries with Highest Death Count per Population

SELECT location, max(CAST(total_deaths AS INT)) AS total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY 2 DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT

SELECT location, max(CAST(total_deaths AS INT)) AS total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY total_death_count DESC

-- Showing Countries with Highest Death Count per Infection

SELECT location,  population, max(total_deaths) AS highest_deaths_count, max(total_cases) AS highest_infection_count, (max(total_deaths) / max(total_cases) * 100) AS max_death_per_cases_rate
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY 5 DESC

-- Showing Continents with Highest Death Count per population

SELECT location, population, max(CAST(total_deaths AS INT)) AS total_death_count, (max(CAST(total_deaths AS INT))/population) * 100 AS death_rate_per_cont
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location, population
ORDER BY total_death_count DESC

-- GLOBAL NUMBERS

SELECT  SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases) * 100 AS death_infec_rate
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1, 2

-- Use CTE
 
 WITH PopVsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
 AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as INT)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated 
--(rolling_people_vaccination/population) * 100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2, 3
)
SELECT *, (rolling_people_vaccinated/population) * 100
FROM PopVsVac

-- TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccination
CREATE TABLE #PercentPopulationVaccination(
continent nvarchar(255),
location nvarchar(255),
Data datetime,
Population numeric,
new_vaccination numeric,
rolling_people_vaccinated numeric,
)

INSERT INTO #PercentPopulationVaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as INT)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated 
--(rolling_people_vaccination/population) * 100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2, 3

SELECT *, (rolling_people_vaccinated/population) * 100
FROM #PercentPopulationVaccination

-- Creating View to store data for later visualisations

CREATE VIEW PercentPopulationVaccination AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as INT)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL

SELECT *
FROM PercentPopulationVaccination