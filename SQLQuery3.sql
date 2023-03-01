--select * 
--from covidDeath
--where continent is not null
--order by 3,4



--select * 
--from CovidVaccination
--order by 3,4

--data we are using
--select location, date,total_cases,new_cases,total_deaths, population
--from covidDeath
--order by 1,2

--Total death vs Total-case
--show likehood of dying if contact covid in your country

--select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
--from covidDeath
--where location like '%Nigeria%'
--order by 1,2


--Total Cases vs Population
--Show what percentage of population got covid

--select location, date,population,total_cases, (total_cases/population)*100 as Deathpercentagebypopulation
--from covidDeath
--where location like '%Nigeria%'
--order by 1,2

--Countries with highest infection rate compared to population

--select location,population ,Max(total_cases) as HighestInfesctionCount, max(total_cases/population)*100 as percentagepopulationaffected
--from covidDeath
----where location like '%Nigeria%'
--group by location , population
--order by percentagepopulationaffected desc


-- Showing the countries with highest death count per population
--select location,Max(cast(total_deaths as int)) as TotalDeathCount 
--from covidDeath
----where location like '%Nigeria%'
--where continent is not null
--group by location
--order by TotalDeathCount desc

--Let's break things down by continent

select continent,Max(cast(total_deaths as int)) as TotalDeathCount 
from covidDeath
--where location like '%Nigeria%'
where continent is not null
group by continent
order by TotalDeathCount desc


--- showing the continent with highest death count per population
select continent,Max(cast(total_deaths as int)) as TotalDeathCount 
from covidDeath
--where location like '%Nigeria%'
where continent is not null
group by continent
order by TotalDeathCount desc


--- correct location querry

--select location,Max(cast(total_deaths as int)) as TotalDeathCount 
--from covidDeath
----where location like '%Nigeria%'
--where continent is null
--group by location
--order by TotalDeathCount desc

---- Global Numbers
--select Sum(new_cases)as total_cases , Sum(cast(new_deaths as int)) as total_deaths,Sum(cast(new_deaths as int))/Sum(New_cases)*100 as DeathPercentage
--from covidDeath
----where location like '%Nigeria%'
--Where continent is not null 
----Group by date
--order by 1,2 

---Joining two tables 

select * 
from covidDeath as dea
join CovidVaccination as vac
on dea.location = vac.location
and dea.date = vac.date

---Total population vs Vaccination



select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location,dea.date) as RollingpeopleVac
from covidDeath as dea
join CovidVaccination as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3 


--USE CTE

with popvsvac( continent ,location , date, population,new_vaccinations,RollingpeopleVac)
as 
(
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location,dea.date) as RollingpeopleVac
from covidDeath as dea
join CovidVaccination as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3 
)
select * ,(RollingpeopleVac/population)*100
from popvsvac

--temp Table

drop table if exists #percentpopulationvac2
create table #percentpopulationvac2
(
continent nvarchar (255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rollingpeoplevac numeric
)
 insert into #percentpopulationvac2
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location,dea.date) as RollingpeopleVac
from covidDeath as dea
join CovidVaccination as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3 

select * ,(RollingpeopleVac/population)*100
from #percentpopulationvac2

--creating views to store for visualization 

create view locationpop as
select location,Max(cast(total_deaths as int)) as TotalDeathCount 
from covidDeath
--where location like '%Nigeria%'
where continent is null
group by location
--order by TotalDeathCount desc
