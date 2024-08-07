-- Data Cleaning

SELECT *
FROM layoffs;

-- Step 1. Remove Duplicates
-- Step 2. Standardize Data
-- Step 3. Null Values or Blank Values
-- Step 4. Remove Any Columns or Rows 

-- Allows for raw data to be accessible in case of mistakes 
CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

-- Remove Duplicates 

-- Creates a row number that is unique to check for duplicates 
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging;

-- Finds duplicate values
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
DELETE
FROM duplicate_cte
WHERE row_num > 1;

-- Verify duplicates
SELECT *
FROM layoffs_staging
WHERE company = 'Casper';

-- Create a layoffs_staging2 table that has row_num to delete duplicates 
CREATE TABLE `layoffs_staging2` (
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

-- Shows duplicates 
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

-- Inserts table value row_num into layoffs_staging2
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, 
stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- Delete duplicate values represented by number higher than 1
DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- Show updated table
SELECT *
FROM layoffs_staging2;

-- Standardizing Data

-- Remove blank white space on left
SELECT company, TRIM(company)
FROM layoffs_staging2;

-- Set to table
UPDATE layoffs_staging2
SET company = TRIM(company);

-- Check industry for issues
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

-- Confirm issue with Crypto values
SELECT *
FROM layoffs_staging2
WHERE industry LIKE'Crypto%';

-- Change to be the same throughout
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT industry
FROM layoffs_staging2;

-- Check for more standardizing issues
SELECT *
FROM layoffs_staging2;

-- Fix '.' at end of United States in one row
SELECT distinct country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

-- Update table 
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Formatting Dates 

-- Format dates 
SELECT `date`,
str_to_date(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

-- Updates dates in table to formatted version
UPDATE layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y');

-- Update `date` to date instead of text
SELECT `date`
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT *
FROM layoffs_staging2;

-- Null and Blank Values

-- Check for null and blank values
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL 
OR industry = '';

-- Populate data that has industry instead of blank
SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

-- Check for blanks and update with industry
SELECT *
FROM layoffs_staging2 T1
JOIN layoffs_staging2 T2
	ON T1.company = T2.company
    AND T1.location = T2.location
WHERE (T1.industry IS NULL OR T1.industry = '')
AND T2.industry IS NOT NULL;

UPDATE layoffs_staging2
SET industry = null
WHERE industry = '';

UPDATE layoffs_staging2 T1
JOIN  layoffs_staging2 T2
	ON T1.company = T2.company
SET T1.industry = T2.industry
WHERE (T1.industry IS NULL OR T1.industry = '')
AND T2.industry IS NOT NULL;

-- Populate and delete null rows
SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%';

SELECT *
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Get rid of the row_num column
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;