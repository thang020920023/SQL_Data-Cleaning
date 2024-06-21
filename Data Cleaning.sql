SELECT *
FROM Portfolio_Project.dbo.NashvilleHousing

------------------------------------------------------------------------------------------
-- Step 1: Standardize Date Format

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM Portfolio_Project.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET Saledate = CONVERT(Date,SaleDate)--Saledate doesn't change as required so I add an column in command below

ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
ADD SaleDateAlter Date;

UPDATE NashvilleHousing
SET SaleDateAlter = CONVERT(Date,SaleDate)

SELECT *
FROM Portfolio_Project.dbo.NashvilleHousing

------------------------------------------------------------------------------------------
-- Step 2: Populate Property Address data

SELECT *
FROM Portfolio_Project.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT 
	a.ParcelID, b.ParcelID, a.UniqueID, b.UniqueID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM 
	Portfolio_Project.dbo.NashvilleHousing a
JOIN 
	Portfolio_Project.dbo.NashvilleHousing b
ON
	a.ParcelID = b.ParcelID
AND
	a.UniqueID <> b.UniqueID
WHERE
	a.PropertyAddress IS NULL

UPDATE a 
SET
	PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM 
	Portfolio_Project.dbo.NashvilleHousing a
JOIN 
	Portfolio_Project.dbo.NashvilleHousing b
ON
	a.ParcelID = b.ParcelID
AND
	a.UniqueID <> b.UniqueID
WHERE
	a.PropertyAddress IS NULL

------------------------------------------------------------------------------------------
-- Step 3: Breaking out Address Into Individual Columns (Address, City, State)

SELECT
	PropertyAddress,
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)- 1) AS PropertyAddressOnly,
	SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS PropertyCityOnly
FROM 
	Portfolio_Project.dbo.NashvilleHousing

ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
ADD PropertyAddressOnly Nvarchar(225);

UPDATE Portfolio_Project.dbo.NashvilleHousing
SET PropertyAddressOnly = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)- 1)

ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
ADD PropertyCityOnly Nvarchar(225);

UPDATE Portfolio_Project.dbo.NashvilleHousing
SET PropertyCityOnly = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM
	Portfolio_Project.dbo.NashvilleHousing

------------------------------------------------------------------------------------------
-- Step 3 (Optional): Using PARSENAME to split the string into smaller pieces by the dot

SELECT
	PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM
	Portfolio_Project.dbo.NashvilleHousing

ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
ADD OwnerAddressOnly Nvarchar(225);

UPDATE Portfolio_Project.dbo.NashvilleHousing
SET OwnerAddressOnly = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
ADD OwnerCityOnly Nvarchar(225);

UPDATE Portfolio_Project.dbo.NashvilleHousing
SET OwnerCityOnly = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
ADD OwnerStateOnly Nvarchar(225);

UPDATE Portfolio_Project.dbo.NashvilleHousing
SET OwnerStateOnly = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT *
FROM
	Portfolio_Project.dbo.NashvilleHousing

------------------------------------------------------------------------------------------
--Step 4: TRANSFORM THE O/1 INTO NO/YES

ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
ALTER COLUMN SoldAsVacant Nvarchar(225)

UPDATE Portfolio_Project.dbo.NashvilleHousing
SET 
	SoldAsVacant =
CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM
	Portfolio_Project.dbo.NashvilleHousing

SELECT DISTINCT(SoldAsVacant)
FROM
	Portfolio_Project.dbo.NashvilleHousing

------------------------------------------------------------------------------------------
--Step 5: Removing Duplicate

WITH NashvilleHousingCTE AS 
(
SELECT *,
		ROW_NUMBER() OVER (
						PARTITION BY
									ParcelID,
									LandUse,
									PropertyAddress,
									SaleDate,
									SalePrice,
									LegalReference,
									OwnerName
									ORDER BY 
										UniqueID
									) num_row
FROM
	Portfolio_Project.dbo.NashvilleHousing
)

SELECT *
FROM NashvilleHousingCTE  
WHERE num_row > 1

DELETE
FROM NashvilleHousingCTE
WHERE num_row > 1

------------------------------------------------------------------------------------------
-- Step 6: Deleting unused Columns

SELECT *
FROM
	Portfolio_Project.dbo.NashvilleHousing

ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, TaxDistrict, OwnerAddress, SaleDate