-- EDA

SELECT *
FROM layoffs_staging2;

#max laid off and max percentage laid off
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

#companies that has 1 were basically bankrupt and want to order by funds raised to see how big, majority are startups
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

#Seeing which company laid off the most
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

#the date range for the layoffs
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

#whihc insustries laid of the most totally, makes sense for retail and consumer during covid periods
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

#which country laid of the most in total
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

#Seeing how many were laid off each year, 2023 is looking bad as it only has data for 1st 3 months
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

#seeing the type of companies that laid off, if they were in early stages etc
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

#not much insight by checking percenatge laid off for each company
SELECT company, SUM(percentage_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;


#getting laid off figures for each month
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

#rolling total CTE ordered by month, see the increase that occured each month
WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off,
SUM(total_off) OVER (ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;


SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

#sum of total laid off by each company for each year and sorting via 3rd column
SELECT company, YEAR(`date`) AS `YEAR`, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, `YEAR`
ORDER BY 3 DESC;

#CTE within a CTE, 1st CTE just got sum of total laid off by each company for each year, 
#2nd CTE used first one to rank the top 5 companies with mose laid off for each year
WITH Company_Year (Company, Years, Total_Laid_Off) AS
(
SELECT company, YEAR(`date`) AS `YEAR`, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, `YEAR`
), Company_Year_Rank AS
(SELECT *, 
DENSE_RANK() OVER (PARTITION BY Years ORDER BY Total_Laid_Off DESC) AS Ranking
FROM Company_Year
WHERE Years IS NOT NULL
AND Total_Laid_Off IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5
;