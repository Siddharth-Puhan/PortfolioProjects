-- Cleaning Data Using SQL

Select *
from PortfolioProject.dbo.NashvilleHousing


-- Standardize date format

Select SaleDate, CONVERT(date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate date

-----------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data

Select *
from PortfolioProject.dbo.NashvilleHousing
where PropertyAddress is null

-- We can use the ParcelID to populate the PropertyAddress rows which are null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Update the table 

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-----------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, State and City)

-- 1. PropertyAddress
Select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing


-- For Showing both the Adress and city separately
-- (-1) to get rid of the comma
Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
from PortfolioProject.dbo.NashvilleHousing



-- Creating columns for storing the PropertyAddress separately
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitAddress Nvarchar(255)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitCity Nvarchar(255)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))




--2. OwnerAddress

Select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing

-- Replace ',' with '.' and then use PARSENAME to separate
Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from PortfolioProject.dbo.NashvilleHousing
--where OwnerAddress is not null

-- Creating columns for storing the OwnerAddress separately
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)



ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)



ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitState Nvarchar(255)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-----------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in the 'SoldAsVacant' field

Select DISTINCT(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant,
CASE when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 END
from PortfolioProject.dbo.NashvilleHousing


UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						else SoldAsVacant
						END
-----------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE as(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
			     PropertyAddress,
				 SalePrice,
				 SaleDate,
				 legalReference
				 ORDER BY
				    UniqueID
	                ) row_num

from PortfolioProject.dbo.NashvilleHousing
)
DELETE
from RowNumCTE
where row_num > 1

-----------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
from PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict, SaleDate
-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------