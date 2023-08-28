SELECT * 
FROM CovidDeaths
WHERE continent is not null
order by 3,4


--SELECT * 
--FROM CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent is not null
order by 1,2

-- looking at total cases vs total deaths
-- shows the likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (cast(total_deaths as numeric)/ cast(total_cases as numeric)) * 100 as Deathperc
FROM CovidDeaths
WHERE location like '%states%'
and continent is not null
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
SELECT location, date, total_cases, population, (cast(total_cases as numeric)/ cast(population as numeric)) * 100 as PercPopulationInfected
FROM CovidDeaths
WHERE location like '%states%'
order by 1,2

-- Looking at Countries with highest Infection Rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, (MAX(cast(total_cases as numeric))/ MAX(cast(population as numeric))) * 100 as PercPopulationInfected
FROM CovidDeaths
GROUP By location, population
order by PercPopulationInfected desc

-- Showing Countries with Highest Death Count per Population
SELECT location,  MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP By location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing continents with the highest death count per population
SELECT continent,  MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP By continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null 
order by 1,2


-- Looking at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition By dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3


-- CTE 

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition By dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac



-- TEMP TABLE
DROP TABLE IF EXISTS  #PercentPopulationVacctinated
Create Table #PercentPopulationVacctinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVacctinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition By dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVacctinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVacctinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition By dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null

Select *
FROM PercentPopulationVacctinated

