/*
COVID-19 DATA EXPLORATION
SKILLS USED: JOINS, CTE'S, TEMP TABLES, WINDOWS FUNCTIONS, AGGREGATE FUNCTIONS, CREATING VIEWS, CONVERTING DATA TYPES
*/

select * from SamplePortfolioProject..CovidDeaths
where continent is not null
order by 3,4

select * from SamplePortfolioProject..CovidVaccinations
where continent is not null
order by 3,4

-- SELECT DATA THAT WE ARE GOING TO BE USING

select location, date, total_cases, new_cases, total_deaths, population  
from SamplePortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- LOOKING AT TOTAL CASES VS TOTAL DEATHS

select location, date, total_cases, total_deaths, 
(cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage  
from SamplePortfolioProject..CovidDeaths
where location = 'Pakistan' and continent is not null
order by 1,2

-- LOOKING AT TOTAL CASES VS POPULATION
-- SHOWS WHAT PERCENTAGE OF POPULATION GOT COVID

select location, date, population, total_cases, 
(cast(total_cases as float)/population) as CasesPercentage  
from SamplePortfolioProject..CovidDeaths
where location = 'Pakistan' and continent is not null
order by 1,2

-- LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION.

select location, population, max(cast(total_cases as float)) as TotalCases,
max(cast(total_cases as float)/population)*100 as PercentagePopulationInfected
from SamplePortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by PercentagePopulationInfected desc

-- SHOWING COUNTRIES WITH THE HIGHEST DEATH COUNT PER POPULATION.

select location, population, max(cast(total_deaths as float)) as TotalDeaths
from SamplePortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by TotalDeaths desc

-- LET'S BREAK THINGS DOWN BY CONTINENT
-- SHOWING CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION

select location, population, max(cast(total_deaths as float)) as TotalDeaths
from SamplePortfolioProject..CovidDeaths
where continent is null and location in ('Asia','Europe','North America', 'South America', 'Africa', 'Oceania')
group by location, population
order by TotalDeaths desc

-- GLOBAL NUMBERS
-- CASES AND DEATHS IN THE WORLD

select sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, 
(sum(cast(new_deaths as float))/sum(cast(new_cases as float)))*100 as DeathPercentage  
from SamplePortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- LOOKING AT TOTAL POPULATION VS VACCINATIONS

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by
dea.location, dea.date) as RollingPeopleVaccinated
from SamplePortfolioProject..CovidDeaths dea
join SamplePortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USING CTE (COMMON TABLE EXPRESSION) [TOTAL POPULATION VS VACCINATIONS]

with PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by
dea.location, dea.date) as RollingPeopleVaccinated
from SamplePortfolioProject..CovidDeaths dea
join SamplePortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated / population) * 100 as PercentagePopulationVaccinated
from PopVsVac

-- USING TEMP TABLES TOTAL [POPULATION VS VACCINATIONS]

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by
dea.location, dea.date) as RollingPeopleVaccinated
from SamplePortfolioProject..CovidDeaths dea
join SamplePortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3
select *, (RollingPeopleVaccinated / population) * 100 as PercentagePopulationVaccinated
from #PercentPopulationVaccinated

-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

create view PercentPopulationVaccinated
as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by
dea.location, dea.date) as RollingPeopleVaccinated
from SamplePortfolioProject..CovidDeaths dea
join SamplePortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select * from PercentPopulationVaccinated