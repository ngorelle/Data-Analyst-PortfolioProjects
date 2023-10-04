
--select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- Show likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where Location like '%states%'
ORDER BY 1,2

-- Looking at Total Cases vs Population

SELECT Location, date, total_cases, Population, (total_cases/population)*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
--Where Location like '%states%'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population)*100) as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
--Where Location like '%states%'
GROUP BY Location, Population
ORDER BY PercentagePopulationInfected DESC

-- Showing the Countries with the Highest Death Count per Population

SELECT Location, MAX(cast (total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where Location like '%states%'
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC


-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing the continents with the Highest death count per Population

SELECT continent, MAX(cast (total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


--GLOBAL NUMBERS

SELECT SUM(new_cases) as Total_new_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage--total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--Where Location like '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs Vaccination

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
select *, (RollingPeopleVaccinated/population)*100 
from PopvsVac


-- TEMP TABLE

DROP Table if EXISTS #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population float,
	New_vaccinations nvarchar(255),
	RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated(Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
	FROM PortfolioProject..CovidDeaths dea
	join PortfolioProject..CovidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
	WHERE dea.continent is not null
	--ORDER BY 2,3

select *, (RollingPeopleVaccinated/Population)*100 
from #PercentPopulationVaccinated


-- Creating View to store data for later Visualizations

Create View PercentPopulationVaccinated as
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
	FROM PortfolioProject..CovidDeaths dea
	join PortfolioProject..CovidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
	WHERE dea.continent is not null
	--ORDER BY 2,3

SELECT * FROM PercentPopulationVaccinated