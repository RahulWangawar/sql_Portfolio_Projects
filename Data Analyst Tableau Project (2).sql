/*
Queries used for Tableau Project
*/



-- Tableau Table 1 

Select 
	SUM(new_cases) as total_cases, 
	SUM(cast(new_deaths as int)) as total_deaths, 
	SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From 
	Portfolio_Project..covid_deaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



-- Tableau Table 2 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select 
	location, 
	SUM(cast(new_deaths as int)) as TotalDeathCount
From 
	Portfolio_Project..covid_deaths
--Where location like '%states%'
Where 
	continent is null 
	and 
	location not in ('World', 'European Union', 'International')
Group by 
	location
Order by TotalDeathCount desc


-- Tableau Table 3

Select 
	Location, Population, 
	MAX(total_cases) as HighestInfectionCount,  
	Max((total_cases/population))*100 as PercentPopulationInfected
From 
	Portfolio_Project..covid_deaths
--Where location like '%states%'
Group by 
	Location, Population
order by 
	PercentPopulationInfected desc


-- Tableau Table 4


Select 
	Location, 
	Population,date, 
	MAX(total_cases) as HighestInfectionCount,  
	Max((total_cases/population))*100 as PercentPopulationInfected
From 
	Portfolio_Project..covid_deaths
--Where location like '%states%'
Group by 
	Location, Population, date
order by 
	PercentPopulationInfected desc













