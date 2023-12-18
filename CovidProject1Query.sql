

Select *
From CovidProject1.dbo.CovidDeaths$
----Where continent is not null

order by 3,4

--Select *
--From CovidProject1.dbo.CovidVaccinations$
--order by 3,4


--Select Data that we are going to be using


Select location, date, total_cases, new_cases, total_deaths, population
From CovidProject1.dbo.CovidDeaths$
order by 1,2




-- Looking at Total Cases vs Total Deaths
--Shows likelihood of fatality if infected

Select location, date, total_cases, total_deaths, CONVERT(float,total_deaths) / CONVERT(float, total_cases)*100 as DeathPercentage
From CovidProject1.dbo.CovidDeaths$
Where location like '%states%'
order by 1,2

--Looking at Total Cases vs. Population
--Shows what percentage of population got Covid

Select location, date, total_cases, population, CONVERT(float,total_cases) / CONVERT(float, population)*100 as InfectedPopulation
From CovidProject1.dbo.CovidDeaths$
--Where location like '%states%'
order by 1,2


--Exploring countries with highest infection rate compared to recorded population

Select location, population, MAX(total_cases) as HighestInfectionCount, Max(CONVERT(float,total_cases) / CONVERT(float, population)*100) as MaxInfectionRate
From CovidProject1.dbo.CovidDeaths$

group by population, location
order by MaxInfectionRate desc


--Looking at countries with highest fatality per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidProject1.dbo.CovidDeaths$
Where continent is not null
group by location
order by TotalDeathCount desc


--Let's explore the totaldeathcount by continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidProject1.dbo.CovidDeaths$
Where continent is not null
group by continent
order by TotalDeathCount desc


--Let's explore the continents with the highest death count

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidProject1.dbo.CovidDeaths$
Where continent is not null
group by continent
order by TotalDeathCount desc


--Looking at the global numbers


Select Sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, nullif(sum(cast(new_deaths as int)),0)/sum(new_cases)*100 as DeathPercentage
From CovidProject1.dbo.CovidDeaths$
Where continent is not null
--Group by date
order by 1,2


-- Looking at the total populations vs vaccinations
--I will also use a CTE to simplify the query 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccines.new_vaccinations
, SUM(cast(vaccines.new_vaccinations as bigint)) OVER (Partition by deaths.location order by deaths.location,
deaths.date) as RollingPeopleVaccinated

From CovidProject1.dbo.CovidDeaths$ deaths
Join CovidProject1.dbo.CovidVaccinations$ vaccines
	ON deaths.location = vaccines.location
	and deaths.date = vaccines.date
where deaths.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Here is the query in the form of a temp table

DROP Table if exists #PercentofPopVaccinated
Create Table #PercentofPopVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentofPopVaccinated

Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccines.new_vaccinations
, SUM(cast(vaccines.new_vaccinations as bigint)) OVER (Partition by deaths.location order by deaths.location,
deaths.date) as RollingPeopleVaccinated

From CovidProject1.dbo.CovidDeaths$ deaths
Join CovidProject1.dbo.CovidVaccinations$ vaccines
	ON deaths.location = vaccines.location
	and deaths.date = vaccines.date
where deaths.continent is not null
order by 2,3 

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentofPopVaccinated


--Creating View to store data for later visulations 

Create View PercentofPopVaccinated as 
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccines.new_vaccinations
, SUM(cast(vaccines.new_vaccinations as bigint)) OVER (Partition by deaths.location order by deaths.location,
deaths.date) as RollingPeopleVaccinated

From CovidProject1.dbo.CovidDeaths$ deaths
Join CovidProject1.dbo.CovidVaccinations$ vaccines
	ON deaths.location = vaccines.location
	and deaths.date = vaccines.date
where deaths.continent is not null


Select *
From PercentofPopVaccinated




