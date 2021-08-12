SELECT *
FROM CovidAnalytics.dbo.CovidDeaths

SELECT *
FROM CovidAnalytics.dbo.CovidVaccinations

-- total cases and death based on location
--- NULL check for continent and location
SELECT DISTINCT(continent)
FROM CovidAnalytics.dbo.CovidDeaths
---- There is null in continent column, so we have to check the location (country data) column for null continent.
SELECT DISTINCT(location)
FROM CovidAnalytics.dbo.CovidDeaths
WHERE continent is null
---- it turns out null continent containing continent information in location (country data). so if we want to analyze based on location, we have to exclude the null continent data.
 
-- Death percentage and Covid infected ratio for every country
SELECT location, 
	SUM(CONVERT(float, new_cases)) as cases, 
	SUM(CONVERT(float, new_deaths)) as deaths, 
	AVG(CONVERT(float, population)) OVER (PARTITION BY location) as population,
	(SUM(CONVERT(float, new_deaths))/SUM(CONVERT(float, new_cases)))*100 as death_percentage,
	(SUM(CONVERT(float, new_cases))/AVG(CONVERT(float, population)) OVER (PARTITION BY location))*100 as infected_percentage
FROM CovidAnalytics.dbo.CovidDeaths
WHERE continent is not null
GROUP BY location, Population
ORDER by death_percentage DESC
--- Vanuatu is the highest death_percentage but with very low infected percentage, because the total cases just 4. so I think Vanuatu is relaively safe. Yemen is the same as Vanuatu, high death_percentage with the low 
--- infected_percentage. I think the highest death_percentage with relatively not safe and hight infected_percentage is Peru wiht 9.2% death and 6.4% infected percentage.

-- Death percentage and Covid infected ratio for every continent
SELECT location,
	SUM(CONVERT(float, new_cases)) as cases, 
	SUM(CONVERT(float, new_deaths)) as deaths,
	AVG(CONVERT(float, population)) OVER (PARTITION BY location) as population,
	(SUM(CONVERT(float, new_deaths))/SUM(CONVERT(float, new_cases)))*100 as death_percentage,
	(SUM(CONVERT(float, new_cases))/AVG(CONVERT(float, population)) OVER (PARTITION BY location))*100 as infected_percentage
FROM CovidAnalytics.dbo.CovidDeaths
WHERE continent is null AND location <> 'International' 
GROUP BY location, Population
ORDER by death_percentage DESC

SELECT location,
	SUM(CONVERT(float, new_cases)) as cases, 
	SUM(CONVERT(float, new_deaths)) as deaths,
	AVG(CONVERT(float, population)) OVER (PARTITION BY location) as population,
	(SUM(CONVERT(float, new_deaths))/SUM(CONVERT(float, new_cases)))*100 as death_percentage,
	(SUM(CONVERT(float, new_cases))/AVG(CONVERT(float, population)) OVER (PARTITION BY location))*100 as infected_percentage
FROM CovidAnalytics.dbo.CovidDeaths
WHERE continent = 'South America' 
GROUP BY location, Population
ORDER by death_percentage DESC
--- South America is the worst continent to handle Covid with the highest death_percentage and highest infected_percentage. Peru, Brazil, Colombia, Argentina and Uruguay are in the hight infected_percentage category.

-- Make a new Common Table Expression for the analysis
WITH maincovid (location, cases, deaths, test, vaccinations, populations, median_age, cardiovasc_death_rate, 
				diabetes_prevalence, female_smokers, male_smokers, handwashing_facilities, hospital_beds_per_thousand, 
				life_expectancy, human_development_index) as
(
SELECT deaths.location,
	SUM(CONVERT(float, new_cases)) as cases, 
	SUM(CONVERT(float, deaths.new_deaths)) as deaths,
	SUM(CONVERT(float, new_tests)) as test,
	SUM(CONVERT(float, new_vaccinations)) as vaccinations,
	AVG(CONVERT(float, population)) OVER (PARTITION BY deaths.location) as population,
	AVG(CONVERT(float, median_age)) OVER (PARTITION BY deaths.location) as median_age,
	AVG(cardiovasc_death_rate) OVER (PARTITION BY deaths.location) as cardiovasc_death_rate,
	AVG(CONVERT(float, diabetes_prevalence)) OVER (PARTITION BY deaths.location) as diabetes_prevalence,
	AVG(CONVERT(float, female_smokers)) OVER (PARTITION BY deaths.location) as female_smokers,
	AVG(CONVERT(float, male_smokers)) OVER (PARTITION BY deaths.location) as male_smokers,
	AVG(handwashing_facilities) OVER (PARTITION BY deaths.location) as handwashing_facilities,
	AVG(CONVERT(float, hospital_beds_per_thousand)) OVER (PARTITION BY deaths.location) as hospital_beds_per_thousand,
	AVG(CONVERT(float, life_expectancy)) OVER (PARTITION BY deaths.location) as life_expectancy,
	AVG(CONVERT(float, human_development_index)) OVER (PARTITION BY deaths.location) as human_development_index
FROM CovidAnalytics.dbo.CovidDeaths as deaths
JOIN CovidAnalytics.dbo.CovidVaccinations as vac
ON deaths.location = vac.location AND deaths.date = vac.date
WHERE deaths.continent is not null
GROUP BY deaths.location, population, median_age, cardiovasc_death_rate, diabetes_prevalence, female_smokers, male_smokers, handwashing_facilities, hospital_beds_per_thousand, life_expectancy, human_development_index
)
SELECT *
from maincovid
