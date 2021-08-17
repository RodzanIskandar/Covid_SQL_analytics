SELECT *
FROM CovidAnalytics.dbo.CovidDeaths
WHERE location = 'Indonesia'

SELECT *
FROM CovidAnalytics.dbo.CovidVaccinations

-- total cases and death based on location
--- NULL check for continent and location
SELECT DISTINCT(continent)
FROM CovidAnalytics.dbo.CovidDeaths
/*There is null in continent column, so we have to check the location (country data) column for null continent.*/
SELECT DISTINCT(location)
FROM CovidAnalytics.dbo.CovidDeaths
WHERE continent is null
/*it turns out null continent containing continent information in location (country data). so if we want to analyze based on location, we have to exclude the null continent data.*/
 
-- Death percentage and Covid infected ratio for every country
SELECT location, 
	MAX(CONVERT(float, total_cases)) as cases, 
	MAX(CONVERT(float, total_deaths)) as deaths, 
	AVG(CONVERT(float, population)) OVER (PARTITION BY location) as population,
	(MAX(CONVERT(float, total_deaths))/MAX(CONVERT(float, total_cases)))*100 as death_percentage,
	(MAX(CONVERT(float, total_cases))/AVG(CONVERT(float, population)) OVER (PARTITION BY location))*100 as infected_percentage
FROM CovidAnalytics.dbo.CovidDeaths
WHERE continent is not null
GROUP BY location, Population
ORDER by death_percentage DESC
/*Vanuatu is the highest death_percentage but with very low infected percentage, because the total cases just 4. so I think Vanuatu is relaively safe. Yemen is the same as Vanuatu, high death_percentage with the low 
infected_percentage. I think the highest death_percentage with relatively not safe and hight infected_percentage is Peru wiht 9.2% death and 6.4% infected percentage.*/

-- Death percentage and Covid infected ratio for every continent
SELECT location,
	MAX(CONVERT(float, total_cases)) as cases, 
	MAX(CONVERT(float, total_deaths)) as deaths, 
	AVG(CONVERT(float, population)) OVER (PARTITION BY location) as population,
	(MAX(CONVERT(float, total_deaths))/MAX(CONVERT(float, total_cases)))*100 as death_percentage,
	(MAX(CONVERT(float, total_cases))/AVG(CONVERT(float, population)) OVER (PARTITION BY location))*100 as infected_percentage
FROM CovidAnalytics.dbo.CovidDeaths
WHERE continent is null AND location <> 'International' 
GROUP BY location, Population
ORDER by death_percentage DESC

SELECT location,
	MAX(CONVERT(float, total_cases)) as cases, 
	MAX(CONVERT(float, total_deaths)) as deaths, 
	AVG(CONVERT(float, population)) OVER (PARTITION BY location) as population,
	(MAX(CONVERT(float, total_deaths))/MAX(CONVERT(float, total_cases)))*100 as death_percentage,
	(MAX(CONVERT(float, total_cases))/AVG(CONVERT(float, population)) OVER (PARTITION BY location))*100 as infected_percentage
FROM CovidAnalytics.dbo.CovidDeaths
WHERE continent = 'South America' 
GROUP BY location, Population
ORDER by death_percentage DESC
/* South America is the worst continent to handle Covid with the highest death_percentage and highest infected_percentage. Peru, Brazil, Colombia, Argentina and Uruguay are in the hight infected_percentage category.*/

-- Make a new Common Table Expression for the analysis
WITH maincovid (continent, location, cases, deaths, tests, vaccinations, populations, median_age, cardiovasc_death_rate, 
				diabetes_prevalence, female_smokers, male_smokers, handwashing_facilities, hospital_beds_per_thousand, 
				life_expectancy, human_development_index) as
(
SELECT deaths.continent,
	deaths.location,
	MAX(CONVERT(float, total_cases)) as cases, 
	MAX(CONVERT(float, total_deaths)) as deaths,
	MAX(CONVERT(float, total_tests)) as tests,
	MAX(CONVERT(float, people_fully_vaccinated)) as vaccinations,
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
GROUP BY deaths.continent, deaths.location, population, median_age, cardiovasc_death_rate, diabetes_prevalence, female_smokers, male_smokers, handwashing_facilities, hospital_beds_per_thousand, life_expectancy, human_development_index
)
SELECT *
from maincovid

-- Vaccination and test percentange analysis
WITH maincovid (continent, location, cases, deaths, tests, vaccinations, populations, median_age, cardiovasc_death_rate, 
				diabetes_prevalence, female_smokers, male_smokers, handwashing_facilities, hospital_beds_per_thousand, 
				life_expectancy, human_development_index) as
(
SELECT deaths.continent,
	deaths.location,
	MAX(CONVERT(float, total_cases)) as cases, 
	MAX(CONVERT(float, total_deaths)) as deaths,
	MAX(CONVERT(float, total_tests)) as tests,
	MAX(CONVERT(float, people_fully_vaccinated)) as vaccinations,
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
GROUP BY deaths.continent, deaths.location, population, median_age, cardiovasc_death_rate, diabetes_prevalence, female_smokers, male_smokers, handwashing_facilities, hospital_beds_per_thousand, life_expectancy, human_development_index
)
SELECT continent,
	location,
	cases,
	deaths,
	populations,
	vaccinations,
	tests,
	(cases/populations)*100 as infected_percentage,
	(deaths/cases)*100 as death_percentage,
	(tests/populations)*100 as test_percentage,
	(vaccinations/populations)*100 as vaccination_percentage
FROM maincovid
WHERE tests is not null
ORDER BY vaccination_percentage DESC

/* from the maincovid table some of the test_percentage data which is test/populations are exceding 100% because test is not limited to one person one test.*/

WITH maincovid (continent, location, cases, deaths, tests, vaccinations, populations, median_age, cardiovasc_death_rate, 
				diabetes_prevalence, female_smokers, male_smokers, handwashing_facilities, hospital_beds_per_thousand, 
				life_expectancy, human_development_index) as
(
SELECT deaths.continent,
	deaths.location,
	MAX(CONVERT(float, total_cases)) as cases, 
	MAX(CONVERT(float, total_deaths)) as deaths,
	MAX(CONVERT(float, total_tests)) as tests,
	MAX(CONVERT(float, people_fully_vaccinated)) as vaccinations,
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
GROUP BY deaths.continent, deaths.location, population, median_age, cardiovasc_death_rate, diabetes_prevalence, female_smokers, male_smokers, handwashing_facilities, hospital_beds_per_thousand, life_expectancy, human_development_index
)
SELECT continent,
	SUM(cases) as cases,
	SUM(deaths) as deaths,
	SUM(tests) as tests,
	SUM(vaccinations) as vaccinations ,
	SUM(populations) as population,
	(SUM(cases)/SUM(populations))*100 as infected_percentage,
	(SUM(deaths)/SUM(cases))*100 as death_percentage,
	(SUM(tests)/SUM(populations))*100 as test_percentage,
	(SUM(vaccinations)/SUM(populations))*100 as vaccination_percentage
FROM maincovid
WHERE tests is not null
GROUP BY continent
ORDER BY vaccination_percentage DESC

/* North America and Europe are ahead with the high vaccination and test percentage while Africa struggling with vaccination with only 2% population are vaccinated in Africa and only 5% of test percentage.*/

WITH maincovid (continent, location, cases, deaths, tests, vaccinations, populations, median_age, cardiovasc_death_rate, 
				diabetes_prevalence, female_smokers, male_smokers, handwashing_facilities, hospital_beds_per_thousand, 
				life_expectancy, human_development_index) as
(
SELECT deaths.continent,
	deaths.location,
	MAX(CONVERT(float, total_cases)) as cases, 
	MAX(CONVERT(float, total_deaths)) as deaths,
	MAX(CONVERT(float, total_tests)) as tests,
	MAX(CONVERT(float, people_fully_vaccinated)) as vaccinations,
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
GROUP BY deaths.continent, deaths.location, population, median_age, cardiovasc_death_rate, diabetes_prevalence, female_smokers, male_smokers, handwashing_facilities, hospital_beds_per_thousand, life_expectancy, human_development_index
)
SELECT continent,
	location,
	cases,
	deaths,
	populations,
	vaccinations,
	tests,
	(cases/populations)*100 as infected_percentage,
	(deaths/cases)*100 as death_percentage,
	(tests/populations)*100 as test_percentage,
	(vaccinations/populations)*100 as vaccination_percentage
FROM maincovid
WHERE tests is not null and continent = 'Africa'
ORDER BY vaccination_percentage DESC

/* In Africa continent only Morocco and Tunisia are with over 10% vaccination percentage beside that below 10%, dominated with only 0.5% - 1% population are vaccination, even in South sudan, Uganda, Cote d'Ivoire , Ethiopia
and Madagascar are nearly zero percent and null percent of population vaccinated.*/

WITH maincovid (continent, location, cases, deaths, tests, vaccinations, populations, median_age, cardiovasc_death_rate, 
				diabetes_prevalence, female_smokers, male_smokers, handwashing_facilities, hospital_beds_per_thousand, 
				life_expectancy, human_development_index) as
(
SELECT deaths.continent,
	deaths.location,
	MAX(CONVERT(float, total_cases)) as cases, 
	MAX(CONVERT(float, total_deaths)) as deaths,
	MAX(CONVERT(float, total_tests)) as tests,
	MAX(CONVERT(float, people_fully_vaccinated)) as vaccinations,
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
GROUP BY deaths.continent, deaths.location, population, median_age, cardiovasc_death_rate, diabetes_prevalence, female_smokers, male_smokers, handwashing_facilities, hospital_beds_per_thousand, life_expectancy, human_development_index
)
SELECT continent,
	location,
	cases,
	deaths,
	populations,
	vaccinations,
	tests,
	(cases/populations)*100 as infected_percentage,
	(deaths/cases)*100 as death_percentage,
	(tests/populations)*100 as test_percentage,
	(vaccinations/populations)*100 as vaccination_percentage
FROM maincovid
WHERE tests is not null and continent = 'Europe'
ORDER BY vaccination_percentage DESC

/* for comparassion, Europe have high percentage in test and vaccination with only 3 countries with vaccination percentage below 10%, Kosovo, Bosnia and Herzegovina and Ukraine and the lowest of test_percentage is Albania with
only 25% of test_percentage which is high for countries in Africa. It shows there are unequal distribution of vaccines for third world nations towards first world nations like Europe and North America countries.*/

-- Median_age on death_percentage
WITH maincovid (continent, location, cases, deaths, tests, vaccinations, populations, median_age, cardiovasc_death_rate, 
				diabetes_prevalence, female_smokers, male_smokers, handwashing_facilities, hospital_beds_per_thousand, 
				life_expectancy, human_development_index) as
(
SELECT deaths.continent,
	deaths.location,
	MAX(CONVERT(float, total_cases)) as cases, 
	MAX(CONVERT(float, total_deaths)) as deaths,
	MAX(CONVERT(float, total_tests)) as tests,
	MAX(CONVERT(float, people_fully_vaccinated)) as vaccinations,
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
GROUP BY deaths.continent, deaths.location, population, median_age, cardiovasc_death_rate, diabetes_prevalence, female_smokers, male_smokers, handwashing_facilities, hospital_beds_per_thousand, life_expectancy, human_development_index
)
SELECT location,
	median_age,
	deaths,
	(deaths/cases)*100 as death_percentage
FROM maincovid
ORDER BY median_age DESC

-- cardiovasc_death_rate on death percentage
WITH maincovid (continent, location, cases, deaths, tests, vaccinations, populations, median_age, cardiovasc_death_rate, 
				diabetes_prevalence, female_smokers, male_smokers, handwashing_facilities, hospital_beds_per_thousand, 
				life_expectancy, human_development_index) as
(
SELECT deaths.continent,
	deaths.location,
	MAX(CONVERT(float, total_cases)) as cases, 
	MAX(CONVERT(float, total_deaths)) as deaths,
	MAX(CONVERT(float, total_tests)) as tests,
	MAX(CONVERT(float, people_fully_vaccinated)) as vaccinations,
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
GROUP BY deaths.continent, deaths.location, population, median_age, cardiovasc_death_rate, diabetes_prevalence, female_smokers, male_smokers, handwashing_facilities, hospital_beds_per_thousand, life_expectancy, human_development_index
)
SELECT location,
	cardiovasc_death_rate,
	deaths,
	(deaths/cases)*100 as death_percentage
FROM maincovid
ORDER BY cardiovasc_death_rate DESC

-- diabetes_prevalence on death percentage
WITH maincovid (continent, location, cases, deaths, tests, vaccinations, populations, median_age, cardiovasc_death_rate, 
				diabetes_prevalence, female_smokers, male_smokers, handwashing_facilities, hospital_beds_per_thousand, 
				life_expectancy, human_development_index) as
(
SELECT deaths.continent,
	deaths.location,
	MAX(CONVERT(float, total_cases)) as cases, 
	MAX(CONVERT(float, total_deaths)) as deaths,
	MAX(CONVERT(float, total_tests)) as tests,
	MAX(CONVERT(float, people_fully_vaccinated)) as vaccinations,
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
GROUP BY deaths.continent, deaths.location, population, median_age, cardiovasc_death_rate, diabetes_prevalence, female_smokers, male_smokers, handwashing_facilities, hospital_beds_per_thousand, life_expectancy, human_development_index
)
SELECT location,
	diabetes_prevalence,
	deaths,
	(deaths/cases)*100 as death_percentage
FROM maincovid
ORDER BY diabetes_prevalence DESC

-- smokers on death percentage
WITH maincovid (continent, location, cases, deaths, tests, vaccinations, populations, median_age, cardiovasc_death_rate, 
				diabetes_prevalence, female_smokers, male_smokers, handwashing_facilities, hospital_beds_per_thousand, 
				life_expectancy, human_development_index) as
(
SELECT deaths.continent,
	deaths.location,
	MAX(CONVERT(float, total_cases)) as cases, 
	MAX(CONVERT(float, total_deaths)) as deaths,
	MAX(CONVERT(float, total_tests)) as tests,
	MAX(CONVERT(float, people_fully_vaccinated)) as vaccinations,
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
GROUP BY deaths.continent, deaths.location, population, median_age, cardiovasc_death_rate, diabetes_prevalence, female_smokers, male_smokers, handwashing_facilities, hospital_beds_per_thousand, life_expectancy, human_development_index
)
SELECT location,
	CONVERT(float, female_smokers) AS female_smokers,
	CONVERT(float, male_smokers) AS male_smokers,
	deaths,
	(deaths/cases)*100 as death_percentage
FROM maincovid
ORDER BY female_smokers DESC

-- hospital_beds_per_thousand on death percentage
WITH maincovid (continent, location, cases, deaths, tests, vaccinations, populations, median_age, cardiovasc_death_rate, 
				diabetes_prevalence, female_smokers, male_smokers, handwashing_facilities, hospital_beds_per_thousand, 
				life_expectancy, human_development_index) as
(
SELECT deaths.continent,
	deaths.location,
	MAX(CONVERT(float, total_cases)) as cases, 
	MAX(CONVERT(float, total_deaths)) as deaths,
	MAX(CONVERT(float, total_tests)) as tests,
	MAX(CONVERT(float, people_fully_vaccinated)) as vaccinations,
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
GROUP BY deaths.continent, deaths.location, population, median_age, cardiovasc_death_rate, diabetes_prevalence, female_smokers, male_smokers, handwashing_facilities, hospital_beds_per_thousand, life_expectancy, human_development_index
)
SELECT location,
	hospital_beds_per_thousand,
	deaths,
	(deaths/cases)*100 as death_percentage
FROM maincovid
ORDER BY hospital_beds_per_thousand DESC

-- life expectancy on death percentage
WITH maincovid (continent, location, cases, deaths, tests, vaccinations, populations, median_age, cardiovasc_death_rate, 
				diabetes_prevalence, female_smokers, male_smokers, handwashing_facilities, hospital_beds_per_thousand, 
				life_expectancy, human_development_index) as
(
SELECT deaths.continent,
	deaths.location,
	MAX(CONVERT(float, total_cases)) as cases, 
	MAX(CONVERT(float, total_deaths)) as deaths,
	MAX(CONVERT(float, total_tests)) as tests,
	MAX(CONVERT(float, people_fully_vaccinated)) as vaccinations,
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
GROUP BY deaths.continent, deaths.location, population, median_age, cardiovasc_death_rate, diabetes_prevalence, female_smokers, male_smokers, handwashing_facilities, hospital_beds_per_thousand, life_expectancy, human_development_index
)
SELECT location,
	life_expectancy
	deaths,
	(deaths/cases)*100 as death_percentage
FROM maincovid
ORDER BY life_expectancy DESC

/* at glance, its shows that all parametes is not very related to death percentage. it will more clear to see the correlation using visualisation in python or another tools for visualisation.*/

-- handwashing_facilities on infected percentage
WITH maincovid (continent, location, cases, deaths, tests, vaccinations, populations, median_age, cardiovasc_death_rate, 
				diabetes_prevalence, female_smokers, male_smokers, handwashing_facilities, hospital_beds_per_thousand, 
				life_expectancy, human_development_index) as
(
SELECT deaths.continent,
	deaths.location,
	MAX(CONVERT(float, total_cases)) as cases, 
	MAX(CONVERT(float, total_deaths)) as deaths,
	MAX(CONVERT(float, total_tests)) as tests,
	MAX(CONVERT(float, people_fully_vaccinated)) as vaccinations,
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
GROUP BY deaths.continent, deaths.location, population, median_age, cardiovasc_death_rate, diabetes_prevalence, female_smokers, male_smokers, handwashing_facilities, hospital_beds_per_thousand, life_expectancy, human_development_index
)
SELECT location,
	handwashing_facilities,
	cases,
	(cases/populations)*100 as infected_percentage
FROM maincovid
ORDER BY handwashing_facilities DESC
/* just the same with previous analysis, at glance its not show the strong effect or correlation betweein handwashing facilities and infected percentage. */

-- human_development_index
WITH maincovid (continent, location, cases, deaths, tests, vaccinations, populations, median_age, cardiovasc_death_rate, 
				diabetes_prevalence, female_smokers, male_smokers, handwashing_facilities, hospital_beds_per_thousand, 
				life_expectancy, human_development_index) as
(
SELECT deaths.continent,
	deaths.location,
	MAX(CONVERT(float, total_cases)) as cases, 
	MAX(CONVERT(float, total_deaths)) as deaths,
	MAX(CONVERT(float, total_tests)) as tests,
	MAX(CONVERT(float, people_fully_vaccinated)) as vaccinations,
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
GROUP BY deaths.continent, deaths.location, population, median_age, cardiovasc_death_rate, diabetes_prevalence, female_smokers, male_smokers, handwashing_facilities, hospital_beds_per_thousand, life_expectancy, human_development_index
)
SELECT location,
	human_development_index,
	(cases/populations)*100 as infected_percentage,
	(deaths/cases)*100 as death_percentage,
	(tests/populations)*100 as test_percentage,
	(vaccinations/populations)*100 as vaccination_percentage
FROM maincovid
ORDER BY human_development_index DESC

/* At glance, human development index are correlated to test percentage, higher the human development index higher the test percentage. The country with over 0.8 human development index tend to have very high test percentage. 
but again it will be more clear if we analyze using visualisation.*/