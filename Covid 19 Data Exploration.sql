/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1,2


--Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 
AS death_percentage
FROM covid_deaths 
WHERE location = 'Turkey'
ORDER BY 2 

--Looking at Total Cases vs Population

SELECT location, date, total_cases, population, (total_cases/population)*100 
AS PercentPopulationInfected 
FROM covid_deaths 
WHERE location = 'Turkey'
ORDER BY 2

--Looking at Countries with Highest Infection rate compared to Population 

SELECT location, population, MAX(total_cases) AS HighestInfectionCount,
MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM covid_deaths 
GROUP BY location,population
ORDER BY PercentPopulationInfected DESC

WITH max_case AS (
SELECT location,date,total_cases,population,(total_cases/population)*100 AS case_percentage,
ROW_NUMBER() OVER(ORDER BY(total_cases/population)*100  DESC) AS rank
FROM covid_deaths  ) 

SELECT location,total_cases,population,case_percentage 
FROM max_case  WHERE rank =1 

--Countries with Highest Death Count per Population

SELECT location,continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount 
FROM covid_deaths WHERE continent IS NOT NULL 
GROUP BY location,continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS  total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, 
SUM(cast(new_deaths AS INT))/SUM(new_cases)*100 AS Death_Percentage
FROM covid_deaths WHERE continent IS NOT NULL

-- Total Population vs Vaccinations

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CONVERT(FLOAT, v.new_vaccinations)) OVER 
(PARTITION BY d.location ORDER BY d.date) AS  rolling_people_vaccinated
FROM covid_vaccinations v JOIN covid_deaths d
ON v.location = d.location AND v.date= d.date 
WHERE d.continent IS NOT NULL   
ORDER BY 2,3

-- Using CTE to perform Calculation on Partition By in previous query

WITH pop_vs_vac AS (
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CONVERT(FLOAT, v.new_vaccinations)) OVER 
(PARTITION BY d.location ORDER BY d.date) AS  rolling_people_vaccinated
FROM covid_vaccinations v JOIN covid_deaths d
ON v.location = d.location AND v.date= d.date 
WHERE d.continent IS NOT NULL   
   )

SELECT *, (rolling_people_vaccinated/population)*100 AS rolling_people_vaccinated_percentage
FROM pop_vs_vac 


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated (
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric)

INSERT INTO #PercentPopulationVaccinated (continent, location,date,population,new_vaccinations,rolling_people_vaccinated)
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CONVERT(FLOAT, v.new_vaccinations)) OVER 
(PARTITION BY d.location ORDER BY d.date) AS  rolling_people_vaccinated
FROM covid_vaccinations v JOIN covid_deaths d
ON v.location = d.location AND v.date= d.date 
WHERE d.continent IS NOT NULL   

SELECT *, (rolling_people_vaccinated/population)*100 AS rolling_people_vaccinated_percentage
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

CREATE VIEW percent_population_vaccinated AS 
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CONVERT(FLOAT, v.new_vaccinations)) OVER 
(PARTITION BY d.location ORDER BY d.date) AS  rolling_people_vaccinated
FROM covid_vaccinations v JOIN covid_deaths d
ON v.location = d.location AND v.date= d.date 
WHERE d.continent IS NOT NULL 
