/*

Cleaning Data 

*/


--Removing unnecessary symbols and characters from the Salary_Estimate column
--Changing Salary_Estimate column name to Salary_Estimate_USD

UPDATE ds_jobs SET Salary_Estimate = REPLACE(Salary_Estimate,'$','')

UPDATE ds_jobs SET Salary_Estimate = REPLACE(Salary_Estimate,'K','')

EXEC sp_rename N'dbo.ds_jobs.Salary_Estimate', N'Salary_Estimate_USD',N'COLUMN'

--Splitting  Salary_Estimate_USD column into min and max

UPDATE ds_jobs 
SET Salary_Estimate_USD = SUBSTRING(Salary_Estimate_USD,1,
LEN(Salary_Estimate_USD)-LEN(SUBSTRING(Salary_Estimate_USD,
CHARINDEX('(',Salary_Estimate_USD),CHARINDEX(')',Salary_Estimate_USD))))

SELECT Salary_Estimate_USD, PARSENAME(REPLACE(Salary_Estimate_USD,'-','.'),2),
PARSENAME(REPLACE(Salary_Estimate_USD,'-','.'),1)
FROM ds_jobs 

ALTER TABLE ds_jobs ADD Salary_Estimate_Min_USD INT
ALTER TABLE ds_jobs ADD Salary_Estimate_Max_USD INT

UPDATE ds_jobs SET Salary_Estimate_Min = PARSENAME(REPLACE(Salary_Estimate_USD,'-','.'),2)
UPDATE ds_jobs SET Salary_Estimate_Max = PARSENAME(REPLACE(Salary_Estimate_USD,'-','.'),1)

-- Removing Rating numbers from Company_Name column

SELECT Rating,Company_Name, SUBSTRING(Company_Name,1,LEN(Company_Name)-LEN(RIGHT(Company_Name,3))) 
FROM  ds_jobs  WHERE  Rating != -1 

UPDATE  ds_jobs set  Company_Name=SUBSTRING(Company_Name,1,LEN(Company_Name)-LEN(RIGHT(Company_Name,3))) 
FROM ds_jobs  where  Rating != -1

-- Removing -1 from Rating,Founded,Size,Sector columns

UPDATE ds_jobs SET Rating =CASE
WHEN Rating=-1 THEN NULL
ELSE Rating
END

UPDATE ds_jobs SET Founded =CASE
WHEN Founded=-1 THEN NULL 
ELSE Founded 
END

UPDATE ds_jobs SET Size =CASE
WHEN Size= '-1' THEN NULL
ELSE Size
END

UPDATE ds_jobs SET Sector =CASE
WHEN Sector= '-1' THEN NULL
ELSE Sector
END

-- Splitting Location column into city and state

SELECT Location,PARSENAME(REPLACE(Location,',','.'),2) ,PARSENAME(REPLACE(Location,',','.'),1) 
FROM ds_jobs 

ALTER TABLE ds_jobs ADD Location_City NVARCHAR(255)
ALTER TABLE ds_jobs ADD Location_State NVARCHAR(255)

UPDATE ds_jobs SET Location_City = PARSENAME(REPLACE(Location,',','.'),2)
UPDATE ds_jobs SET Location_State =TRIM(PARSENAME(REPLACE(Location,',','.'),1))

--Changing  some values ​​in the Location_State column with their abbreviations 
--and those that are not appropriate with Null

SELECT Location_City,Location_State 
FROM  ds_jobs WHERE Location_City IS NULL

UPDATE ds_jobs SET Location_State = CASE Location_State 
WHEN  'Utah' THEN 'UT' 
WHEN  'New Jersey' THEN 'NJ' 
WHEN  'Texas' THEN 'TX' 
WHEN  'California' THEN 'CA' 
WHEN  'United States' THEN NULL 
WHEN  'Remote' THEN NULL 
ELSE Location_State 
END

--Splitting Headquarters column into city,state,country

UPDATE ds_jobs SET Headquarters =CASE
WHEN Headquarters= '-1' THEN NULL
ELSE Headquarters
END

SELECT Headquarters, PARSENAME(REPLACE(Headquarters,',','.'),1),PARSENAME(REPLACE(Headquarters,',','.'),2)
FROM ds_jobs 

ALTER TABLE ds_jobs ADD Headquarters_City NVARCHAR(255)
ALTER TABLE ds_jobs ADD Headquarters_State NVARCHAR(255)
ALTER TABLE ds_jobs ADD Headquarters_Country NVARCHAR(255)

UPDATE ds_jobs SET Headquarters_State = PARSENAME(REPLACE(Headquarters,',','.'),1)
UPDATE ds_jobs SET Headquarters_City = PARSENAME(REPLACE(Headquarters,',','.'),2)
 
UPDATE ds_jobs
SET Headquarters_Country = Headquarters_State

UPDATE ds_jobs SET Headquarters_Country=CASE 
WHEN LEN(TRIM(Headquarters_Country))= 2 THEN  'USA' 
ELSE TRIM(Headquarters_Country) 
END  

UPDATE ds_jobs SET Headquarters_State=CASE 
WHEN LEN(TRIM(Headquarters_State))<>2 THEN NULL 
ELSE TRIM(Headquarters_State) 
END  

--Removing Duplicates

WITH duplicate_values AS(
SELECT Job_Title,Salary_Estimate_USD,Rating,Company_Name ,ROW_NUMBER() OVER (PARTITION BY Job_Title,Salary_Estimate_USD,Rating,Company_Name
ORDER BY Job_Title) AS rank
FROM ds_jobs )

DELETE FROM duplicate_values WHERE rank>1

-- Deleting Unused Columns

ALTER TABLE ds_jobs 
DROP COLUMN Location,Headquarters,Competitors
