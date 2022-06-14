--SELECT *)
--FROM PortfolioProject..covidDeaths
--WHERE continent NOT IN ('')

SELECT *
FROM PortfolioProject..covidVaccinations
ORDER BY 1, 2;

-- Selecting data in advance
SELECT location, cast(global_date as date), total_cases, new_cases, total_deaths, population
FROM PortfolioProject..covidDeaths
WHERE continent NOT IN ('')
ORDER BY 1, 2;

-- Total Cases vs Total Deaths
SELECT location, MAX(cast(total_cases as bigint)) AS total_cases, MAX(cast(total_deaths as bigint)) AS total_deaths
FROM PortfolioProject..covidDeaths
WHERE continent NOT IN ('')
GROUP BY location
ORDER BY 1;

-- Total Cases vs Total Deaths across the time
SELECT location, cast(global_date as date), total_cases, total_deaths, cast(total_deaths as bigint)/NULLIF(cast(total_cases as float),0)*100 AS deathPercentage
FROM PortfolioProject..covidDeaths
WHERE continent NOT IN ('')
ORDER BY 1,2; 

-- Looking at countries with hightest death percentage amoung infections
SELECT location, AVG(cast(total_deaths as bigint)/NULLIF(cast(total_cases as float),0)*100) AS deathPercentage
FROM PortfolioProject..covidDeaths
WHERE continent NOT IN ('')
GROUP BY location
ORDER BY 2 DESC; 

-- Looking into the Mexico's information

-- Percentage of population that got Covid
SELECT location, cast(global_date as date) AS date, population, total_cases, cast(total_cases as bigint)/cast(population as float)*100 AS percentagePopulationInfected
FROM PortfolioProject..covidDeaths
WHERE location like '%mexico'
ORDER BY 1,2; 

-- Countries with the Highest infection rate compared to population
SELECT location, population, MAX(cast(total_cases as bigint)) as HighestInfectionCount, MAX(cast(total_cases as float)/NULLIF(cast(population as bigint),0))*100 AS percentagePopulationInfected
FROM PortfolioProject..covidDeaths
WHERE continent NOT IN ('')
GROUP BY location, population
ORDER BY 4 DESC; 

-- Countries with the Highest death count by population
SELECT location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
FROM PortfolioProject..covidDeaths
WHERE continent NOT IN ('')
GROUP BY location
ORDER BY 2 DESC; 

-- Breaking down data by continent/global

-- Total deaths by continent
SELECT continent, MAX(cast(total_deaths as bigint)) as TotalDeathCount
FROM PortfolioProject..covidDeaths
WHERE continent NOT IN ('')
GROUP BY continent
ORDER BY 2 DESC; 

-- Global death percentage
SELECT cast(global_date as date), SUM(cast(new_cases as bigint)) AS totalCases, SUM(cast(new_deaths as bigint)) AS totalDeaths,
SUM(cast(new_deaths as float))/NULLIF(SUM(cast(new_cases as bigint)),0)*100 AS deathPercentageGlobal
FROM PortfolioProject..covidDeaths
WHERE continent NOT IN ('')
GROUP BY global_date
ORDER BY 1,2;  

-- TODO fix this get the day with maximun death percentage
--SELECT g_query.deathPercentageGlobal
--FROM(SELECT cast(global_date as date), SUM(cast(new_deaths as float))/NULLIF(SUM(cast(new_cases as bigint)),0)*100 AS deathPercentageGlobal
--FROM PortfolioProject..covidDeaths
--WHERE continent NOT IN ('')
--GROUP BY global_date) AS g_query;


-- Joining deaths and vaccinations tables
SELECT *
FROM PortfolioProject..covidDeaths cDea JOIN PortfolioProject..covidVaccinations cVac 
ON cDea.location = cVac.location AND cDea.global_date = cVac.date;

-- Total population vs Vaccinations
SELECT cDea.continent, cDea.location, cast(cDea.global_date as date), cDea.population, cVac.new_vaccinations
FROM PortfolioProject..covidDeaths cDea JOIN PortfolioProject..covidVaccinations cVac 
ON cDea.location = cVac.location AND cDea.global_date = cVac.date
WHERE cDea.continent NOT IN ('')
ORDER BY 2, 3;


-- Total population vaccinations compared to deaths
SELECT cDea.continent, cDea.location, MAX(cast(cDea.total_deaths as bigint)) AS total_deaths, MAX(cast(cVac.total_vaccinations as bigint)) AS total_vaccinations
FROM PortfolioProject..covidDeaths cDea JOIN PortfolioProject..covidVaccinations cVac 
ON cDea.location = cVac.location AND cDea.global_date = cVac.date
WHERE cDea.continent NOT IN ('')
GROUP BY cDea.continent, cDea.location
ORDER BY 1, 2;

-- Total of deaths and vaccinations by location, taking the Maximun number as the total
SELECT cDea.continent, cDea.location, MAX(cast(cDea.total_deaths as bigint)) AS total_deaths, MAX(cast(cVac.total_vaccinations as bigint)) AS total_vaccinations
FROM PortfolioProject..covidDeaths cDea JOIN PortfolioProject..covidVaccinations cVac 
ON cDea.location = cVac.location AND cDea.global_date = cVac.date
WHERE cDea.continent NOT IN ('') AND cVac.continent NOT IN ('')
GROUP BY cDea.continent, cDea.location
ORDER BY 1, 2;

-- Total of deaths and vaccinations by location, using new_vaccinations_smoothed as new_vaccinations columns is missing information,
-- as new_vaccinations_smoothed is a smoothed variable, we get lower numbers
SELECT cDea.continent, cDea.location, SUM(cast(cDea.new_deaths as bigint)) AS total_deaths, SUM(cast(cVac.new_vaccinations_smoothed as bigint)) AS total_vaccinations
FROM PortfolioProject..covidDeaths cDea JOIN PortfolioProject..covidVaccinations cVac 
ON cDea.location = cVac.location AND cDea.global_date = cVac.date
WHERE cDea.continent NOT IN ('') AND cVac.continent NOT IN ('')
GROUP BY cDea.continent, cDea.location
ORDER BY 1, 2;

-- Partition by
SELECT cDea.continent, cDea.location, CONVERT(date, cVac.date) AS date, CONVERT(bigint, cDea.population),  CONVERT(bigint, cVac.new_vaccinations), 
SUM(CONVERT(float, cVac.new_vaccinations)) OVER (Partition by cDea.location ORDER BY cDea.location, cDea.global_date) as RollingPeopleVaccinated
FROM PortfolioProject..covidDeaths cDea JOIN PortfolioProject..covidVaccinations cVac 
ON cDea.location = cVac.location AND cDea.global_date = cVac.date
WHERE cDea.continent NOT IN ('');

-- Using a CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS(
SELECT cDea.continent, cDea.location, CONVERT(date, cVac.date) AS date, CONVERT(bigint, cDea.population),  CONVERT(bigint, cVac.new_vaccinations), 
SUM(CONVERT(float, cVac.new_vaccinations)) OVER (Partition by cDea.location ORDER BY cDea.location, cDea.global_date) as RollingPeopleVaccinated
FROM PortfolioProject..covidDeaths cDea JOIN PortfolioProject..covidVaccinations cVac 
ON cDea.location = cVac.location AND cDea.global_date = cVac.date
WHERE cDea.continent NOT IN ('')
)
SELECT *, (RollingPeopleVaccinated/NULLIF(population, 0))*100
FROM PopvsVac;

-- Temp Table
DROP Table If exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT cDea.continent, cDea.location, CONVERT(date, cVac.date) AS date, CONVERT(bigint, cDea.population),  CONVERT(bigint, cVac.new_vaccinations), 
SUM(CONVERT(float, cVac.new_vaccinations)) OVER (Partition by cDea.location ORDER BY cDea.location, cDea.global_date) as RollingPeopleVaccinated
FROM PortfolioProject..covidDeaths cDea JOIN PortfolioProject..covidVaccinations cVac 
ON cDea.location = cVac.location AND cDea.global_date = cVac.date
WHERE cDea.continent NOT IN ('')

SELECT *, (RollingPeopleVaccinated/NULLIF(population, 0))*100
FROM #PercentPopulationVaccinated;

-- Creating views to store data for later visualizations
Create View WorldWideDeaths as
SELECT continent, MAX(cast(total_deaths as bigint)) as TotalDeathCount
FROM PortfolioProject..covidDeaths
WHERE continent NOT IN ('')
GROUP BY continent 