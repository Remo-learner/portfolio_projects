SELECT *
 FROM layoffs;
 
 -- Crating a duplicate table to work with
 
 Create table layoff_staging
 like layoffs;
 
 Insert into layoff_staging (
 Select * 
 From layoffs
 );


SELECT *
 FROM layoff_staging;
 
-- Checking and removing duplicates


 with cte_duplicate as 
 (
  SELECT * ,row_number() over(partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
 FROM layoff_staging
 )
 select *
 from cte_duplicate 
 where row_num > 1 ;
 
 CREATE TABLE `layoff_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoff_staging2 
(
  SELECT * ,row_number() over(partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
 FROM layoff_staging
);

Delete 
from layoff_staging2
where row_num > 1 ;

-- Standadizing names

select Distinct(company)
 FROM layoff_staging2
 order by 1
 ;
 
 UPDATE layoff_staging2
 SET company = trim(company);
 
select Distinct(industry)
 FROM layoff_staging2
 order by 1
 ;
 
 UPDATE layoff_staging2
 SET industry = "Crypto"
 Where industry like "Crypto%";
 
 -- Standadizing names
 
select `date` ,`date` = str_to_date(`date`,"%m/%d/%Y")
 FROM layoff_staging2
 ;
 
 UPDATE layoff_staging2
 Set `date` = str_to_date(`date`,"%m/%d/%Y");
 
 ALTER TABLE layoff_staging2
 MODIFY COLUMN `date` date ;
 
 -- Fixing countries names
  
select distinct country
 FROM layoff_staging2
order by 1
 ;
 
 UPDATE layoff_staging2
 SET country = "United States"
 Where country like "United States%";
 
-- Populating the missing data
   
select  *
FROM layoff_staging2
order by 1
 ;
 
 Update layoff_staging2
 SET industry = null 
 Where industry = "";
 
 
 SELECT * 
 FROM layoff_staging2 as tb1
 join layoff_staging2 as tb2
 on tb1.company = tb2.company
 where tb1.industry is null and tb2.industry is not null ;
 
UPDATE layoff_staging2 as tb1
join layoff_staging2 as tb2
 on tb1.company = tb2.company
set tb1.industry = tb2.industry
where tb1.industry is null and tb2.industry is not null ;

 
  Select *
 from layoff_staging2;

-- Deleting useless columns
 
 ALTER TABLE layoff_staging2
 drop column row_num;
 
 -- Having a look at the data 
 
 Select substring(`date`,1,7) as `month`,sum(total_laid_off) as laid_off
 from layoff_staging2
 where substring(`date`,1,7) is not null
 group by `month`
 order by `month`;
 
 -- Ranking companies based of laidoffs each year
 
 with company_years as 
 (
  Select company,year(`date`) as years,sum(total_laid_off) as laid_off
 from layoff_staging2
 where substring(`date`,1,7) is not null
 group by company,`years`
 order by 1
 ), company_ranking as(
 select *,dense_rank() over(partition by years order by laid_off desc) as ranking
 from company_years
 where laid_off is not null)
 select *
 from company_ranking 
 where ranking <= 5 ;
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

