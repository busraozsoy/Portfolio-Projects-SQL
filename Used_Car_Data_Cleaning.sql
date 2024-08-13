SELECT * FROM used_car_sales

--Removing unnecessary symbols and characters from the miles column

SELECT miles,SUBSTRING(miles,1,CHARINDEX(' ',miles)-1)
FROM used_car_sales

UPDATE used_car_sales SET miles =  SUBSTRING(miles,1,CHARINDEX(' ',miles)-1)

--Splitting  condition column into owner_counts and _reported_accident_counts

SELECT SUBSTRING(ltrim(PARSENAME(REPLACE(condition,',','.'),1)),1,1)
FROM used_car_sales

ALTER TABLE used_car_sales ADD owner_counts int
UPDATE used_car_sales SET owner_counts =SUBSTRING(ltrim(PARSENAME(REPLACE(condition,',','.'),1)),1,1)

SELECT  SUBSTRING(ltrim(PARSENAME(REPLACE(condition,',','.'),2)),1,2)
FROM used_car_sales
ALTER TABLE used_car_sales ADD _reported_accident_counts nvarchar(50)
UPDATE used_car_sales SET _reported_accident_counts =SUBSTRING(ltrim(PARSENAME(REPLACE(condition,',','.'),2)),1,2)


UPDATE used_car_sales SET _reported_accident_counts = CASE _reported_accident_counts 
WHEN  'No' THEN '0' 
ELSE _reported_accident_counts 
END

--Splitting  color column into interior_color and exterior_color

SELECT  LTRIM(PARSENAME(REPLACE(color,',','.'),1)),PARSENAME(REPLACE(color,',','.'),2) FROM used_car_sales

ALTER TABLE used_car_sales ADD interior_color varchar(255)
ALTER TABLE used_car_sales ADD exterior_color varchar(255)

UPDATE used_car_sales SET interior_color=LTRIM(PARSENAME(REPLACE(color,',','.'),1))
UPDATE used_car_sales SET exterior_color=PARSENAME(REPLACE(color,',','.'),2)


SELECT  SUBSTRING(interior_color,1,CHARINDEX(' ',interior_color)-1) FROM used_car_sales
SELECT  SUBSTRING(exterior_color,1,CHARINDEX(' ',exterior_color)-1) FROM used_car_sales

UPDATE used_car_sales SET interior_color=SUBSTRING(interior_color,1,CHARINDEX(' ',interior_color)-1)
UPDATE used_car_sales SET exterior_color= SUBSTRING(exterior_color,1,CHARINDEX(' ',exterior_color)-1)

--Removing Duplicates

WITH duplicate AS (
SELECT * ,ROW_NUMBER() OVER(PARTITION BY name,year,miles,price ORDER BY year)  as duplicate_values  
FROM used_car_sales)

DELETE FROM duplicate WHERE duplicate_values>1

--SELECT duplicate_values FROM duplicate WHERE duplicate_values>1


-- Delete Unused Columns

ALTER TABLE used_car_sales
DROP COLUMN condition, color