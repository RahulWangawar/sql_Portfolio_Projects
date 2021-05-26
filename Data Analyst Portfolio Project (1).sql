/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

select * 
from Portfolio_Project..covid_deaths
order by 3,4

-- In the location we have continents like Asia,Europe...we need to
-- delete those rows having continent as NULL 

SELECT *
FROM Portfolio_Project..covid_deaths
WHERE continent is not NULL
ORDER BY 3,4

-- Correct selection of observation using where keyword

select location,date,total_cases,new_cases,population
from Portfolio_Project..covid_deaths
WHERE continent is not NULL
order by 1,2

--Looking at total cases vs total Deaths
-- check the datatype of total_deaths and cast it into int

select location,date,total_cases,total_deaths,(cast(total_deaths as int)/total_cases)*100 as DeathPercentage
from Portfolio_Project..covid_deaths
where location = 'India' 
order by 1,2


--Looking at Total cases vs population

select location,date,total_cases,population,total_deaths,(total_cases/population)*100 as InfectionPercentage
from Portfolio_Project..covid_deaths
where location = 'India'
order by 1,2


-- Highest infection rate country compared to population

select location, MAX(total_cases) as Highest_Cases,
population, MAX(total_cases / population )*100 AS Infection_Rate 
from Portfolio_Project..covid_deaths
WHERE continent is not NULL 
--WHERE location = 'India'
GROUP BY location,population
order by 4 DESC


-- Countries with highest death count per population

SELECT location,MAX(CONVERT(INT,Total_Deaths)) as Total_deaths
FROM
Portfolio_Project..covid_deaths
WHERE continent is not NULL
GROUP BY location
ORDER BY 2 DESC
   

-- continent wise break down

select location, MAX(cast(total_deaths as int)) as Total_Deaths
from Portfolio_Project..covid_deaths
--WHERE location = 'India'
WHERE continent is NULL
GROUP BY location
order by 2 desc


select continent, MAX(cast(total_deaths as int)) as Total_Deaths
from Portfolio_Project..covid_deaths
WHERE continent is not NULL
GROUP BY continent
order by 2 desc


-- Globle data breakdown

select date,SUM(total_cases) AS totalCases,
SUM(new_cases) AS New_Cases,
SUM(cast(new_deaths as int)) AS New_Deaths,
SUM(cast(new_deaths as int))/SUM(new_cases) * 100 AS DeathPercentage
from Portfolio_Project..covid_deaths
--WHERE location = 'India' and new_cases >0 and new_deaths >= 0
WHERE continent is not NULL
GROUP BY date--,location
order by date 


---------- Vaccination dataset-------

SELECT * FROM Portfolio_Project..covid_vaccination

-- TOTAL POPULATION Vs VACCINATION
SELECT dea.continent, dea.location,dea.date,
dea.population,vac.new_vaccinations, 
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ) AS Total_Vaccinated
FROM Portfolio_Project..covid_deaths AS dea
JOIN Portfolio_Project..covid_vaccination AS vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..covid_deaths dea
Join Portfolio_Project..covid_vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3





-- Using CTEs We can perform opertion on newly created column

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated )
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..covid_deaths dea
Join Portfolio_Project..covid_vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
select *,(RollingPeopleVaccinated/population)*100 as Percentage_population_vaccinated 
From PopvsVac



-- using Temp table
DROP Table IF EXISTS #percentPopulationVaccinated
create Table #percentPopulationVaccinated
(continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

insert into #percentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..covid_deaths dea
Join Portfolio_Project..covid_vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

select *, 
(RollingPeopleVaccinated/population)*100 as Percentage_population_vaccinated 
FROM #percentPopulationVaccinated


--create view to store data for later visualization

create view percentPopulationVaccinated
as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..covid_deaths dea
Join Portfolio_Project..covid_vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3