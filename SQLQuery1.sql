/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, 
Creating Views, Converting Data Types

*/


SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
Where location like 'Malaysia'
ORDER BY 1,2

-- Infection rate per country

SELECT location, date, total_cases, population, (total_cases/population)*100 AS Infection_Rate
FROM PortfolioProject..CovidDeaths
Where location like '%malaysia%'
ORDER BY 1,2


-- Looking at countries with highest Infection Rate

SELECT location,population, MAX(cast(total_cases as INT)) as HighestInfectionCount, MAX(total_cases/population)*100 AS Infection_Rate
FROM PortfolioProject.dbo.CovidDeaths
--Where location like '%malaysia%'
Group BY Location, population
ORDER BY 4 DESC


--showing Countries with Highest Death Count per population

SELECT location, MAX(cast(total_deaths as INT)) as TotalDeathCount 
FROM PortfolioProject.dbo.CovidDeaths
--Where location like '%malaysia%'
Where continent is not null
Group BY Location
ORDER BY 2 DESC

SELECT location,MAX(cast(total_deaths as INT)) as TotalDeathCount, AVG(population) 
FROM PortfolioProject.dbo.CovidDeaths
--Where location like '%malaysia%'
Where continent is null
Group BY location
ORDER BY 2 DESC

--continent death per population

SELECT continent, MAX(cast(total_deaths as INT)) as TotalDeathCount 
FROM PortfolioProject.dbo.CovidDeaths
--Where location like '%malaysia%'
Where continent is not null
Group BY continent
ORDER BY 2 DESC


-- GLOBAL NUMBERS
SELECT date, sum(new_cases) as New_Cases, SUM(cast(new_deaths as int)) as New_Deaths, SUM(cast(new_deaths as int))/Nullif(sum(new_cases),0)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
Group by date
ORDER BY 1,2

-- GLOBAL NUMBERS
SELECT sum(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/Nullif(sum(new_cases),0)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--ORDER BY 1,2


--Looking at Total Population vs Vaccinations
Select dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as Total_Vac
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3


--USE CTE

with Pop_vs_Vac (Continent,location, Date, Population, New_Vaccination, Total_Vac)

as
(
Select dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as Total_Vac
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)

Select*,(Total_Vac/population)*100
From Pop_vs_Vac
Order  by 1,2



-- TEMP TABLE
DRop Table if exists #Percent_Population_Vac
Create Table #Percent_Population_Vac
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #Percent_Population_Vac
Select dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
Select*,(RollingPeopleVaccinated/population)*100
From #Percent_Population_Vac

--Creating View to store data for Later Visualisations

Create View PercentPopulationVaccinated as
Select dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as Total_Vac
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null


select*
From PercentPopulationVaccinated