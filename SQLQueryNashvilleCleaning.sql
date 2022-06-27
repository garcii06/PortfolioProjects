
UPDATE Nashville1  
SET PropertyAddress = ISNULL(Nashville1.PropertyAddress, Nashville2.PropertyAddress)
FROM PortfolioNashville..NashvilleHouses Nashville1 JOIN PortfolioNashville..NashvilleHouses Nashville2
	ON Nashville1.ParcelID = Nashville2.ParcelID AND Nashville1.[UniqueID ] <> Nashville2.[UniqueID ]
WHERE Nashville1.PropertyAddress IS NULL;

/*
	Breaking down Property Address into Individual Columns (Address, City)
*/
SELECT *
FROM PortfolioNashville..NashvilleHouses;

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
FROM PortfolioNashville..NashvilleHouses;

ALTER TABLE NashvilleHouses
ADD PropertyAddressSplit Nvarchar(255);

ALTER TABLE NashvilleHouses
ADD PropertyCitySplit Nvarchar(255);

UPDATE NashvilleHouses
SET PropertyAddressSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

UPDATE NashvilleHouses
SET PropertyCitySplit = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

/*
	Breaking down Owner Address into Individual Columns (Address, City, State)
*/
SELECT *
FROM PortfolioNashville..NashvilleHouses;

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),	--Address
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),	--City
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)	--State
FROM PortfolioNashville..NashvilleHouses;

ALTER TABLE NashvilleHouses
ADD OwnerAddressSplit Nvarchar(255);

ALTER TABLE NashvilleHouses
ADD OwnerCitySplit Nvarchar(255);

ALTER TABLE NashvilleHouses
ADD OwnerStateSplit Nvarchar(255);

UPDATE NashvilleHouses
SET OwnerAddressSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

UPDATE NashvilleHouses
SET OwnerCitySplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

UPDATE NashvilleHouses
SET OwnerStateSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

/*
	Changing SoldAsVacant String into char option
*/
SELECT *
FROM PortfolioNashville..NashvilleHouses;

SELECT CASE SoldAsVacant
	WHEN 'Yes' THEN 'Y'
	WHEN 'No' THEN 'N'
	ELSE SoldAsVacant
END
FROM PortfolioNashville..NashvilleHouses;

UPDATE NashvilleHouses
SET SoldAsVacant = 
CASE SoldAsVacant
	WHEN 'Yes' THEN 'Y'
	WHEN 'No' THEN 'N'
	ELSE SoldAsVacant
END;

/*
	Remove duplicates in SQL with a CTE
*/
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY 
						UniqueID) row_num

FROM PortfolioNashville..NashvilleHouses)

DELETE
FROM RowNumCTE
WHERE row_num > 1;

/*
	Creating a view and deleting columns from tables
*/

CREATE VIEW [Owner Info] AS
SELECT UniqueID, ParcelID, OwnerName, OwnerAddress, OwnerAddressSplit, OwnerCitySplit, OwnerStateSplit
FROM PortfolioNashville..NashvilleHouses;

SELECT *
FROM PortfolioNashville..[Owner Info];

ALTER VIEW [Owner Info] AS
SELECT UniqueID, ParcelID, OwnerName, OwnerAddressSplit, OwnerCitySplit, OwnerStateSplit
FROM PortfolioNashville..NashvilleHouses;

/*
	Dropping columns from the original table
*/
SELECT *
FROM PortfolioNashville..NashvilleHouses;

ALTER TABLE NashvilleHouses
DROP COLUMN SaleDate; --Other columns
