-- Looking at whole data

select *
from CovidProject.dbo.CovidDeaths
order by location, date

select *
from CovidProject.dbo.CovidVaccinations

-- Select data that we are start to work with

select location, date, total_cases, new_cases, total_deaths, new_deaths
from CovidProject.dbo.CovidDeaths
where continent is not null
order by 1, 2

-- Total cases vs total deaths
-- Showing as percentage of people who died on Covid 19 compare to all Covid 19 cases

Select location, date, total_cases, new_cases, total_deaths, new_deaths, (total_deaths/total_cases)*100 as death_percentage
from CovidProject.dbo.CovidDeaths
where continent is not null
order by 1, 2

-- Total cases vs population
-- Percentage of people infected by Covid 19

Select location, date, total_cases, population, (total_cases/population)*100 as people_infected_percentage
from CovidProject.dbo.CovidDeaths
where continent is not null
order by 1, 2

-- Countries with the higiest infection rate compare to population

select location, population, max(total_cases) as maximum_cases, max((total_cases/population))*100 as Percente_population_infected
from CovidProject.dbo.CovidDeaths
where continent is not null 
--and location = 'Poland'
group by location, population
order by Percente_population_infected desc

-- Countries with the highiest death count

select location, max(cast(total_deaths as int)) as Total_death_count
from CovidProject.dbo.CovidDeaths
where continent is not null 
--and location = 'Poland'
group by location
order by Total_death_count desc

-- Continents with the highiest death count

select continent, max(cast(total_deaths as int)) as Total_death_count
from CovidProject.dbo.CovidDeaths
where continent is not null 
--and location = 'Poland'
group by continent
order by Total_death_count desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidProject.dbo.CovidDeaths
--Where location = 'Poland'
where continent is not null 
--Group By date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(CONVERT(int, v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as Rolling_people_vaccinated
from CovidProject.dbo.CovidDeaths d
join CovidProject.dbo.CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
order by 2, 3

-- Using previous querry as a CTE to calculate percentage of people vaccinated in every country

with popvsvac as 
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(CONVERT(int, v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as Rolling_people_vaccinated
from CovidProject.dbo.CovidDeaths d
join CovidProject.dbo.CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
--order by 2, 3
)
Select *,
(Rolling_people_vaccinated/population)*100 as Percentage_people_vaccinated
from popvsvac
--where location = 'Poland'
order by location, date

-- Do the same querry above but using temp table
DROP TABLE if exists #PercentagePeopleVaccinated
Create table #PercentagePeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_people_vaccinated numeric
)

Insert into #PercentagePeopleVaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(CONVERT(int, v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as Rolling_people_vaccinated
from CovidProject.dbo.CovidDeaths d
join CovidProject.dbo.CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
--order by 2, 3

select *,
(Rolling_people_vaccinated/population)*100 as Percentage_people_vaccinated
from #PercentagePeopleVaccinated
order by location, date

--Creating view for the future visualization

Create view PercentagePeopleVaccinated as
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(CONVERT(int, v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as Rolling_people_vaccinated
from CovidProject.dbo.CovidDeaths d
join CovidProject.dbo.CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
