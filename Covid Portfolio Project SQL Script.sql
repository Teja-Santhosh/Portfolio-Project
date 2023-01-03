/*

Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

select *
from PortfolioProject..CovidDeaths
--where continent is not null
order by 3, 4

select *
from PortfolioProject..CovidVaccinations
order by 3, 4

--Required Data

SELECT location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Total cases vs Total deaths (Death Rate) in India

select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100, 2) as 'Death_rate(%)'
from PortfolioProject..CovidDeaths
where location = 'India'
order by 1,2

-- Total cases vs Population (Infection Rate)

select location, date, total_cases, population, round((total_cases/population)*100, 2) as 'infect_rate(%)'
from PortfolioProject..CovidDeaths
--where location = 'India'
order by 1,2

--Countries with highest infection rate compared to population

select location, population, MAX(total_cases) as highest_infect_count, MAX(round((total_cases/population)*100, 2)) as 'highest_infect_rate(%)'
from PortfolioProject..CovidDeaths
group by location, population
order by [highest_infect_rate(%)] desc

-- Countries with highest death counts

select location, MAX(cast(total_deaths as int)) as highest_death_count
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by highest_death_count desc


--Based on Continents
-- Continents with highest death counts

select continent, MAX(cast(total_deaths as int)) as highest_death_count
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by highest_death_count desc

--Global Numbers

select SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as 'Death_rate(%)'
from PortfolioProject..CovidDeaths
--where location = 'India'
where location is not null
--group by date
order by 1,2

-- Joining Deaths and Vaccinations Tables

select *
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
    on dea.location = vac.location
    and dea.date = vac.date

-- Total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location,
dea.date) as rolling_people_vaccinated--, (rolling_people_vaccinated/new_vaccinations)*100
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- CREATING A CTE 

WITH PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location,
dea.date) as rolling_people_vaccinated--, (rolling_people_vaccinated/population)*100
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rolling_people_vaccinated/population)*100 as vaccination_rate
from PopvsVac

-- CREATING A TEMP TABLE

DROP TABLE IF EXISTS #Percent_Population_Vaccinated
CREATE TABLE #Percent_Population_Vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

Insert into #Percent_Population_Vaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location,
dea.date) as rolling_people_vaccinated--, (rolling_people_vaccinated/population)*100
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
    on dea.location = vac.location
    and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (rolling_people_vaccinated/population)*100 as vaccination_rate
from #Percent_Population_Vaccinated


-- CREATING A VIEW FOR VISUALIZATION

CREATE VIEW 
Percent_Population_Vaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location,
dea.date) as rolling_people_vaccinated--, (rolling_people_vaccinated/population)*100
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null


