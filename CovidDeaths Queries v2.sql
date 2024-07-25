SELECT *
FROM [Portfolio Project - Covid]..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM [Portfolio Project - Covid]..CovidVaccinations
--ORDER BY 3,4


--Select Data that we are going to be using
SELECT Location,date,total_cases, new_cases,total_deaths,population
FROM [Portfolio Project - Covid]..CovidDeaths
Order by 1,2

-- looking at Total Cases vs Total Deaths

SELECT Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project - Covid]..CovidDeaths
WHERE location LIKE '%states'
Order by 1,2

--looking at total cases vs population

SELECT Location,date,population,total_cases, (total_cases/population)*100 as PercantageInfected
FROM [Portfolio Project - Covid]..CovidDeaths
--WHERE location LIKE '%states'
Order by 1,2

-- looking at Countries with highest infection rates compared to population
SELECT Location,Population, MAX(total_cases) as HighestInfectionperCountry,Max((total_cases/population))*100 as PercentPopulationInfected
FROM [Portfolio Project - Covid]..CovidDeaths
Group by Population, Location
Order by PercentPopulationInfected desc

--Showing countries with the highest death count per population
--added  Cast .....as int as numbers
--addded NOT NULL for CONTINENT as it was population continents like Asia, Africa, etc

SELECT Location, MAX(cast (total_deaths as int)) as Total_Deaths
FROM [Portfolio Project - Covid]..CovidDeaths
WHERE continent is not null
Group by Location
Order By Total_Deaths desc

----lets break things down by continent
-- numbers were wrong as much of the locations where in "world' continent so hard to break down by continent

Select location, MAX(cast (total_deaths as int)) as Total_Deaths
FROM [Portfolio Project - Covid].dbo.CovidDeaths
WHERE continent is null
Group by location
Order by Total_Deaths DESC


--PROBLEM BEGINS HERE
--Global Numbers of total cases, total deaths, deathpercentage per day


SELECT 
date,
sum(new_cases) as total_cases, 
Sum(cast (new_deaths as int)) as total_deaths, 
SUM(cast (new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM [Portfolio Project - Covid]..CovidDeaths
WHERE continent is not null
GROUP by date
Order by 1,2

--joined both tables
Select*
FROM [Portfolio Project - Covid]..CovidDeaths dea
JOIN [Portfolio Project - Covid]..CovidVaccinations vacs
	ON dea.location = vacs.location
	and dea.date = vacs.date



	--Looking at total population vs Vaccination 
Select dea.continent, dea.location, dea.date, dea.population, vacs.new_vaccinations,
sum(cast(vacs.new_vaccinations as int)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingVaccinations
--,(RollingVaccination/population)*100 Can't use new column that was just created to divide, you should use a CTE or a temp table
FROM [Portfolio Project - Covid]..CovidDeaths dea
JOIN [Portfolio Project - Covid]..CovidVaccinations vacs
	ON dea.location = vacs.location
	and dea.date = vacs.date
Where dea.continent is not null
Order by 2,3


--OPTION 1 for issue below
--USE CTE for above comment rollingVaccination/population)*100

WITH PopvsVac (continent, location, date, population,new_vaccinations,RollingVaccinations) as
--copied the above right below
-- number of columns in CTE must have the same number of columns as the Select statement below
(
Select dea.continent, dea.location, dea.date, dea.population, vacs.new_vaccinations,
sum(cast(vacs.new_vaccinations as int)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingVaccinations
--,(RollingVaccination/population)*100 Can't use new column that was just created to divide, you should use a CTE or a temp table
FROM [Portfolio Project - Covid]..CovidDeaths dea
JOIN [Portfolio Project - Covid]..CovidVaccinations vacs
	ON dea.location = vacs.location
	and dea.date = vacs.date
Where dea.continent is not null
--Order by 2,3 cannot have order by in CTE
)
Select *, (RollingVaccinations/Population)*100 as 'Percentage vaccinated' -- now that we created CTE, we can use this to get rollingvaccition divided by population*100 to get rate of vacacination
FROM PopvsVac


--OPTION 2 
-- CREATE TEMP Table

DROP TABLE if exists #PercentPopulationVaccinated -- added drop table in case we need to make adjustments to the temp table, allows us to delete current and create new temp table
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingVaccinations numeric,
)

INSERT INTO #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vacs.new_vaccinations,
sum(cast(vacs.new_vaccinations as int)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingVaccinations
--,(RollingVaccination/population)*100 Can't use new column that was just created to divide, you should use a CTE or a temp table
FROM [Portfolio Project - Covid]..CovidDeaths dea
JOIN [Portfolio Project - Covid]..CovidVaccinations vacs
	ON dea.location = vacs.location
	and dea.date = vacs.date
--Where dea.continent is not null
Order by 2,3

Select *, (RollingVaccinations/Population)*100 as 'Percentage vaccinated'
FROM #PercentPopulationVaccinated

--PROBLEM ENDS HERE

--------------

--Creating view to store data for later visualization in Tableua or PowerBI
-- see Views folder to left

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vacs.new_vaccinations,
sum(cast(vacs.new_vaccinations as int)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingVaccinations
--,(RollingVaccination/population)*100 Can't use new column that was just created to divide, you should use a CTE or a temp table
FROM [Portfolio Project - Covid]..CovidDeaths dea
JOIN [Portfolio Project - Covid]..CovidVaccinations vacs
	ON dea.location = vacs.location
	and dea.date = vacs.date
--Where dea.continent is not null
--Order by 2,3
