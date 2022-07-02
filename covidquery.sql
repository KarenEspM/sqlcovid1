--select *
--From covid_deaths
--Order by 3,4

--Select * 
--From covid_vaccinnations
--Order by 3, 4

Select Location, date, total_cases, new_cases, total_deaths, population
From covid_deaths
Order by 1,2

-- Looking at total cases vs total death

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From covid_deaths
Where location = 'United States'
Order by 1,2

-- Looking at total cases vs population
Select Location, date, total_cases, population, (total_cases/population) * 100 as PopulationPercentage
From covid_deaths
Where location = 'United States'
Order by 1,2

--Looking at countries at highest infection compared to population

Select Location,Population, max(total_cases) as HighestInfectionCount, 
max((total_cases/population)) * 100 as PercentPopulationInfected
From covid_deaths
Group by Location, population
Order by PercentPopulationInfected DESC

--Showing total deaths per country
Select location, max(cast(total_deaths as Int)) as TotalDeathCount
From covid_deaths
Where Continent is not null
Group by location
Order by TotalDeathCount Desc

--Showing total deaths per continent
Select continent, max(cast(total_deaths as Int)) as TotalDeathCount
From covid_deaths
Where Continent is not null
Group by continent
Order by TotalDeathCount Desc

--Looking at continent with highest infection compared to population

Select continent, max(total_cases) as HighestInfectionCount, 
max((total_cases/population)) * 100 as PercentPopulationInfected
From covid_deaths
Where continent is not null
Group by continent
Order by PercentPopulationInfected DESC

-- Global numbers
Select date, sum(new_cases) as TotalCasesPerDay, sum(cast(new_deaths as int)) as TotalDeathsPerDay,
sum(cast(new_deaths as int))/sum(new_cases)* 100 as DeathPercentage
From covid_deaths
Where continent is not null
Group by date
Order by 1,2

Select sum(new_cases) as TotalCasesPerDay, sum(cast(new_deaths as int)) as TotalDeathsPerDay,
sum(cast(new_deaths as int))/sum(new_cases)* 100 as DeathPercentage
From covid_deaths
Where continent is not null
--Group by date
Order by 1,2


--Looking at Total Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT))  OVER (PARTITION BY dea.location Order by dea.location, dea.date) as RollingPeopleVaccinnated
From covid_deaths dea
join covid_vaccinnations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

--Using CTE
With PopsVac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT))  OVER (PARTITION BY dea.location Order by dea.location, dea.date) as RollingPeopleVaccinnated
From covid_deaths dea
join covid_vaccinnations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (rollingpeoplevaccinated/population) * 100 as RollingPopulationVaccinated
From PopsVac

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT))  OVER (PARTITION BY dea.location Order by dea.location, dea.date) as RollingPeopleVaccinnated
From covid_deaths dea
join covid_vaccinnations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *, (rollingpeoplevaccinated/population) * 100 as RollingPopulationVaccinated
from #PercentPopulationVaccinated
Order by 2,3

--Creating view for future visualations
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT))  OVER (PARTITION BY dea.location Order by dea.location, dea.date) as RollingPeopleVaccinnated
From covid_deaths dea
join covid_vaccinnations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null