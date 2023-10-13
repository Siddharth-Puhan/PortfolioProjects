select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4;

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying after contracting covid
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths
where location like 'india'
order by 1,2


-- Looking at the Total Cases Vs Population
-- Shows what percentage of population got covid
select location, date, population, total_cases, (total_cases/population)*100 as Case_Percentage
from PortfolioProject..CovidDeaths
where location like 'india'
order by 1,2

-- Looking at countries with the Highest Infection Rate compared to Population
select location, population, MAX(total_cases) as Highest_Infection_Count, 
MAX((total_cases/population)*100) as Percent_Population_Infected

from PortfolioProject..CovidDeaths
group by location, population
order by Percent_Population_Infected desc

-- Breaking things down by continent

-- Showing continents with the highest Death Count per population
select continent, MAX(cast(total_deaths as int)) as Total_Death_Count
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by Total_Death_Count desc


-- GLOBAL NUMBERS

Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) 
as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths
where continent is not null
Group by date
order by 1,2



-- Joining the Covid Death and Covid Vaccination tables
select *
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date


-- Looking at Total Population Vs Vaccinations
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


-- Looking at the total vaccinations for each location
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as Rolling_Total_Vaccination
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Total Vaccination Vs population 
with PopvsVac (continent, location, date, population, new_vaccinations, Rolling_Total_Vaccination)
as
(
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as Rolling_Total_Vaccination
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select *, (Rolling_Total_Vaccination/population)*100
from PopvsVac;



-- Total Percentage Population Vaccinated across each location

with PopvsVac (continent, location, population, new_vaccinations, Rolling_Total_Vaccination)
as
(
select dea.continent, dea.location, population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as Rolling_Total_Vaccination
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select continent, location, population,MAX(new_vaccinations) as total_vaccinations, 
MAX((Rolling_Total_Vaccination/population)*100) as Percent_total_vaccination
from PopvsVac
Group by continent,location, population
order by 1,2,3;




-- Creating view to store data for later visualizations

create view Percent_Population_Vaccinated as
select dea.continent, dea.location, population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as Rolling_Total_Vaccination
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null



select * from Percent_Population_Vaccinated