/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
From CovidData..CovidDeaths
Where continent is not null 
order by 3,4


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidData..CovidDeaths
Where continent is not null 
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidData..CovidDeaths
Where location like '%states%'
and continent is not null 
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From CovidData..CovidDeaths
--Where location like '%states%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidData..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidData..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidData..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidData..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Total population vs vaccinations
-- Looking at total number of vaccinations in pop

SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, 
SUM(CAST(Vac.new_vaccinations as int)) OVER (partition by Dea.location order by Dea.location, Dea.date)
as UpdatedTotalVaccination
FROM CovidData..CovidDeaths Dea
JOIN CovidData..CovidVaccinations Vac
ON Dea.location = Vac.location
AND Dea.date = Vac.date
WHERE Dea.continent is not null
order by 2,3

-- Using CTE to find % of vaccinated population

with PopvsVac (continent, location, date, population, new_vaccinations ,UpdatedTotalVaccination)
as
(
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, 
SUM(CAST(Vac.new_vaccinations as int)) OVER (partition by Dea.location order by Dea.location, Dea.date)
as UpdatedTotalVaccination
FROM CovidData..CovidDeaths Dea
JOIN CovidData..CovidVaccinations Vac
ON Dea.location = Vac.location
AND Dea.date = Vac.date
WHERE Dea.continent is not null
)
SELECT *, (UpdatedTotalVaccination/population) * 100 as UpdatedVaccinationPercentage
FROM PopvsVac

-- Selecting views For Later Visualizations
Create view VaccinatedPercentage as
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(CAST(Vac.new_vaccinations as int)) OVER (partition by Dea.location order by Dea.location, Dea.date)
as UpdatedTotalVaccination
FROM CovidData..CovidDeaths Dea
JOIN CovidData..CovidVaccinations Vac
ON Dea.location = Vac.location
AND Dea.date = Vac.date
WHERE Dea.continent is not null







