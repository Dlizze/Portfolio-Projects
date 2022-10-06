 --To see the columns data type
 --select * from information_schema.columns 
 --WHERE TABLE_NAME = 'CovidDeaths'


Select *
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 3,4


-- Select Data that we are going to be starting with
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2

-- Cumulative Covid Cases by Country
select location, date, sum(new_cases) over (partition by location order by location,date) as cumulative_sum_cases 
From PortfolioProject..CovidDeaths
where location <> continent

-- Total Cases vs Total Deaths
-- Shows the likelihood of death after contracting covid in your country
Select location, date, total_cases, total_deaths, total_deaths/total_cases * 100 as death_percentage
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2

-- Total Cases vs Population
Select location, date, total_cases, population, total_cases/population * 100 as percentpopulationinfected
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2

-- Highest infection rate by country
Select location, population, max(total_cases) as highestinfectioncount, max(total_cases)/population * 100 as percentpopulationinfected
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by location, population
Order by 4 desc

-- Highest Death count per Population
Select location, population, max(cast(total_deaths as int)) as deathcount, max(total_deaths)/population * 100 as percentpopulationdeath
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by location, population
Order by 3 desc

-- Continent stats

--Select location, max(cast(total_deaths as int)) as deathcount
--From PortfolioProject..CovidDeaths
--where continent is null and location not like '%income%'
--group by location
--order by 2 desc

Select continent, max(cast(total_deaths as int)) as deathcount
From PortfolioProject..CovidDeaths
where continent is not null 
group by continent
order by deathcount desc

-- Continent total death per population

Select continent, max(cast(population as int)) as population,max(cast(total_deaths as int)) as deathcount
From PortfolioProject..CovidDeaths
where continent is not null 
group by continent
order by deathcount desc

-- GLOBAL stats

select date, sum(total_cases) as total_cases
from PortfolioProject..CovidDeaths
group by date
order by date

select 
	sum(new_cases) as total_cases, 
	sum(cast(new_deaths as int)) as total_deaths, 
	sum(cast(new_deaths as int))/sum(new_cases) * 100 as death_percentage
from PortfolioProject..CovidDeaths;

-- Join Vaccination table
-- Total Pop vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as cumulative_vaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With cte (continent, location, date, population, new_vaccinations, cumulative_vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as cumulative_vaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)

select *,cumulative_vaccinated/population * 100 as percentage
from cte

-- TEMP Table

DROP TABLE if exists percent_population_vaccinated

CREATE TABLE percent_population_vaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population bigint,
new_vaccinations bigint,
cumulative_vaccinated bigint
)

INSERT INTO percent_population_vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as cumulative_vaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 