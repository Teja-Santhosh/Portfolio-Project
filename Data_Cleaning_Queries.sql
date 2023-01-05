/*
Cleaning Data in SQL Queries
*/


Select *
From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select sale_date_converted--, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET sale_date_converted = CONVERT(Date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress) ) as City

From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add Property_split_address nvarchar(250);

Update NashvilleHousing
SET Property_split_address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 );

ALTER TABLE NashvilleHousing
Add Property_split_city nvarchar(250);

Update NashvilleHousing
SET Property_split_city = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select Property_split_address, Property_split_city
From PortfolioProject.dbo.NashvilleHousing

select PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add Owner_split_address nvarchar(250);

Update NashvilleHousing
SET Owner_split_address = PARSENAME(REPLACE(OwnerAddress,',','.'), 3);

ALTER TABLE NashvilleHousing
Add Owner_split_city nvarchar(50);

Update NashvilleHousing
SET Owner_split_city = PARSENAME(REPLACE(OwnerAddress,',','.'), 2);

ALTER TABLE NashvilleHousing
Add Owner_split_state nvarchar(10);

Update NashvilleHousing
SET Owner_split_state = PARSENAME(REPLACE(OwnerAddress,',','.'), 1);

--select Owner_split_city
--from PortfolioProject..NashvilleHousing
--where Owner_split_city like '%GOOD%%'

-----------------------------------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in 'Sold as Vacant' field

select (SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by (SoldAsVacant)
order by 2


select SoldAsVacant,
CASE When SoldAsVacant = 'Y' then 'Yes'
	 When SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 END
from PortfolioProject..NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant =  CASE When SoldAsVacant = 'Y' then 'Yes'
	 When SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 END

------ TRIED AN ALTERNATE METHOD 

--select REPLACE(SoldAsVacant,'N','No'), SoldAsVacant
--from PortfolioProject..NashvilleHousing
--where SoldAsVacant = 'N'

--select REPLACE(SoldAsVacant,'Y','Yes'), SoldAsVacant
--from PortfolioProject..NashvilleHousing
--where SoldAsVacant = 'Y'

----------------------------------------------------------------------------------------------------------------------------------------

-- Removing Duplicates

WITH row_numCTE as (
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
					) as row_num

from PortfolioProject..NashvilleHousing
)
select *
from row_numCTE
where row_num > 1

--------------------------------------------------------------------------------------------------------------------

-- Deleting Unused Columns

Select *
From PortfolioProject.dbo.NashvilleHousing
order by [UniqueID ]

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN  PropertyAddress, OwnerAddress, SaleDate, TaxDistrict
