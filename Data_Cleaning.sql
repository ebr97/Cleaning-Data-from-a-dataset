/*

Cleaning Data in SQL queries

*/

SELECT * FROM DataAnalystPortofolio.dbo.NashvilleHousing;
--------------------------------------------------------------------------------------------

--Standardize Date Format

SELECT SaleDate, CAST(SaleDate AS DATE) SaleDateStandardize
FROM DataAnalystPortofolio.dbo.NashvilleHousing;

UPDATE DataAnalystPortofolio.dbo.NashvilleHousing
SET SaleDate = CAST(Saledate AS DATE);
--this is not working properly so we try another method

ALTER TABLE DataAnalystPortofolio.dbo.NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE DataAnalystPortofolio.dbo.NashvilleHousing
SET SaleDateConverted = CAST(SaleDate AS DATE);
--now it's working :)

--------------------------------------------------------------------------------------------

--Populate Property Address Data

SELECT *
FROM DataAnalystPortofolio.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL;
ORDER BY ParcelID;

SELECT a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM DataAnalystPortofolio.dbo.NashvilleHousing a
JOIN DataAnalystPortofolio.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL; --here we made an self join because we search after the Properties that have PropertyAddress null to populate them
								 --so we indetify them after ParcellID but have to have different UniqueID becuase we don't want to change th eproperties that already have an address
								 --basically we searched after properties that are in the same parcell that don't have an address with the one's that have an address

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM DataAnalystPortofolio.dbo.NashvilleHousing a
JOIN DataAnalystPortofolio.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL; --here is the update to not have nulls anymore :)

--------------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)

SELECT * FROM DataAnalystPortofolio.dbo.NashvilleHousing

SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1),
	TRIM(SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)-LEN(CHARINDEX(',',PropertyAddress))))
FROM DataAnalystPortofolio.dbo.NashvilleHousing


ALTER TABLE DataAnalystPortofolio.dbo.NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);


UPDATE DataAnalystPortofolio.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1);
--we add street address column
-------------------------------
ALTER TABLE DataAnalystPortofolio.dbo.NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE DataAnalystPortofolio.dbo.NashvilleHousing
SET PropertySplitCity = TRIM(SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)-LEN(CHARINDEX(',',PropertyAddress))));
--we add city column

--------------------------------------------------------------------------------------------

SELECT OwnerAddress FROM DataAnalystPortofolio.dbo.NashvilleHousing

SELECT 
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM DataAnalystPortofolio.dbo.NashvilleHousing

ALTER TABLE DataAnalystPortofolio.dbo.NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE DataAnalystPortofolio.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE DataAnalystPortofolio.dbo.NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE DataAnalystPortofolio.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE DataAnalystPortofolio.dbo.NashvilleHousing
ADD OwnerSplitState NVARCHAR(255)

UPDATE DataAnalystPortofolio.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--------------------------------------------------------------------------------------------

--Change Y and N to yes and No in 'Sold as Vacant' field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM DataAnalystPortofolio.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2
-- we have N, Yes, Y, No


SELECT SoldAsVacant,
	   CASE 
			WHEN SoldAsVacant = 'Y' THEN 'Yes'
		    WHEN SoldAsVacant = 'N' THEN  'No'
			ELSE SoldAsVacant
	   END
FROM DataAnalystPortofolio.dbo.NashvilleHousing

UPDATE DataAnalystPortofolio.dbo.NashvilleHousing
SET SoldAsVacant = CASE 
						WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN  'No'
						ELSE SoldAsVacant
				   END

--------------------------------------------------------------------------------------------

--Remove Duplicates
WITH RowNumCTE AS(
SELECt *, 
		ROW_NUMBER() OVER (PARTITION BY 
										ParcelID,
										PropertyAddress,
										SalePrice,
										SaleDate,
										LegalReference
						   ORDER BY 
								UniqueID
										) row_num
FROM  DataAnalystPortofolio.dbo.NashvilleHousing
--ORDER BY ParcelID
)
DELETE RowNumCTE
WHERE row_num > 1
-- don't do this on raw data without a backup

--------------------------------------------------------------------------------------------

--Delete Unused Columns

SELECT * FROM DataAnalystPortofolio.dbo.NashvilleHousing

ALTER TABLE DataAnalystPortofolio.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress
-- don't do this on raw data without a backup

