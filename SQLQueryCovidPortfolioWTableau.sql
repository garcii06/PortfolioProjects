/*
	Queries for Tableau Visualization 
*/

-- 1. 
SELECT SUM(cast(new_cases as int))  as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(cast(new_cases as float))*100 as DeathPercentage
FROM PortfolioProject..covidDeaths
WHERE continent NOT IN ('')
ORDER BY 1, 2;

-- 2. 
-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe
SELECT location, SUM(cast(new_deaths as int)) as TotalDeathCount
FROM PortfolioProject..covidDeaths
WHERE continent NOT IN ('')
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- 3.
SELECT Location, CONVERT(bigint, population) AS Population, MAX(cast(total_cases as bigint)) AS HighestInfectionCount,  MAX((cast(total_cases as bigint)/NULLIF(cast(population as float), 0)))*100 AS PercentPopulationInfected
FROM PortfolioProject..covidDeaths
GROUP BY location, Population
ORDER BY PercentPopulationInfected DESC;


-- 4.
SELECT Location, CONVERT(bigint, population) AS Population,cast(global_date as date), MAX(cast(total_cases as bigint)) as HighestInfectionCount, MAX((cast(total_cases as bigint)/NULLIF(cast(population as float), 0)))*100 AS PercentPopulationInfected
FROM PortfolioProject..covidDeaths
GROUP BY location, Population, global_date
ORDER BY PercentPopulationInfected DESC;

--5.
-- Breakdown by year
SELECT YEAR(CONVERT(date, cVac.date)), cDea.continent, cDea.location,MAX(cast(cDea.total_deaths as bigint)) AS totalDeaths, MAX(cast(cVac.total_vaccinations as bigint)) AS totalVaccinations,
MAX(cast(cVac.total_tests as bigint)) AS totalTests, MAX((cast(total_cases as bigint)/NULLIF(cast(cVac.population as float), 0)))*100 AS PercentPopulationInfected
FROM PortfolioProject..covidDeaths cDea JOIN PortfolioProject..covidVaccinations cVac 
ON cDea.location = cVac.location AND cDea.global_date = cVac.date
WHERE cDea.continent NOT IN ('')
GROUP BY YEAR(CONVERT(date, cVac.date)), cDea.continent, cDea.location
ORDER BY YEAR(CONVERT(date, cVac.date)) ASC;