/*

Cleaning Data 

*/



-- Standardize Date Format

ALTER TABLE nashville_housing 
ADD SALEDATE_Converted DATE
 
UPDATE nashville_housing  SET SALEDATE_Converted = CONVERT(DATE, SALEDATE)



-- Populate Property Address Data

SELECT a.UniqueID,a.ParcelID ,a.PropertyAddress,b.UniqueID,b.ParcelID,b.PropertyAddress,
ISNULL(a.PropertyAddress,b.PropertyAddress) 
FROM nashville_housing a JOIN nashville_housing b 
ON   a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL 

UPDATE a SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress) 
FROM nashville_housing a JOIN nashville_housing b 
ON   a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL 



-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress ,SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress)) AS City
FROM nashville_housing

ALTER TABLE nashville_housing
ADD PropertySplitAddress nvarchar(255)

UPDATE  nashville_housing 
SET  PropertySplitAddress=SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE nashville_housing
ADD PropertySplitCity nvarchar(255)

UPDATE nashville_housing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress)) 

SELECT * FROM nashville_housing

 
 SELECT OwnerAddress,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3 ) AS ADDRESS,
 PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2 ) AS CÝTY,
 PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1 ) AS STATE
 FROM nashville_housing

ALTER TABLE nashville_housing 
ADD OwnerSplitAddress Nvarchar(255)

UPDATE nashville_housing 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3 )

ALTER TABLE nashville_housing 
ADD OwnerSplitCity Nvarchar(255)

UPDATE nashville_housing 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2 )

ALTER TABLE nashville_housing 
ADD OwnerSplitState Nvarchar(255)

UPDATE nashville_housing 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1 )



-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT SoldAsVacant,COUNT(SoldAsVacant) FROM nashville_housing 
GROUP BY SoldAsVacant

UPDATE  nashville_housing SET SoldAsVacant =CASE

WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END



-- Remove Duplicates

WITH RowNumCTE AS(
Select *,ROW_NUMBER() OVER (
PARTITION BY ParcelID,PropertyAddress,SalePrice, SaleDate,LegalReference
ORDER BY UniqueID) row_num
FROM nashville_housing
)

DELETE 
From RowNumCTE
Where row_num > 1

Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



-- Delete Unused Columns

ALTER TABLE nashville_housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
