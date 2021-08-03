
SELECT * FROM PortfolioProject..CovidDeaths
ORDER BY 3, 4;


--SELECT * FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4;

SELECT location, date, total_cases, new_cases, total_deaths
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2;



-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths,
(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'India'
ORDER BY 1, 2;



-- Total Cases vs Population
-- Shows what % of population got infected

SELECT location, date, Population, total_cases,
(total_cases/Population)*100 AS PercentageCases
FROM PortfolioProject..CovidDeaths
-- WHERE location = 'India'
ORDER BY 1, 2;



-- Looking at countries with Highest Infection rate compared to population

SELECT location, Population, MAX(total_cases) AS HighestInfectionCount ,
MAX(total_cases/Population)*100 AS PercentageInfectionRate
FROM PortfolioProject..CovidDeaths
-- WHERE location = 'India'
GROUP BY Population, Location
ORDER BY PercentageInfectionRate DESC;



-- Countries with Highest Death Count per Population

SELECT location, MAX(cast (total_deaths AS int)) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths
-- WHERE location = 'India'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC;



--DeathCount per Population By Continent

SELECT Continent, MAX(CAST(total_deaths AS INT)) AS Total_Deaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent;



--Global Numbers

SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, 
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL;



-- Total Population vs Vaccination

With PopVsVac
 (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
 AS
 (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location 
ORDER BY dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL  
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS RollingPercent
FROM PopVsVac



-- Now Using a Temp Table 
 
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location 
ORDER BY dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL  

SELECT *, (RollingPeopleVaccinated/Population)*100 AS RollingPercent
FROM #PercentPopulationVaccinated



-- Creating Views for later Visualizaion

CREATE VIEW Percent_PopulationVaccinated AS

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location 
ORDER BY dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL  
--ORDER BY 2,3

SELECT * FROM Percent_PopulationVaccinated
