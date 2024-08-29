/* Cleaning Data in SQL*/

SELECT * 
FROM PortfolioProject..Nashville

--1.Standarize Date Format.
--Changing Column Format from DateTime to Just Date.

SELECT SaleDate, Convert(Date,SaleDate)
FROM PortfolioProject..Nashville

ALTER TABLE Nashville
ALTER COLUMN SaleDate DATE

----------------------------------------------------------------------------------------------------
--2.Populate Property Address Data
--Using Property Address from same customers with different UniqueID to fill in the Null spaces. 

SELECT PropertyAddress
FROM PortfolioProject..Nashville
Where PropertyAddress is Null
order by ParcelID

--Content Prep. Runned also after Update to make sure there were no Nulls left.
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..Nashville a
Join PortfolioProject..Nashville b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is Null

Update a
SET  PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..Nashville a
Join PortfolioProject..Nashville b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is Null

-------------------------------------------------------------------------------------------------------
--3.Breaking out Address into Individual Columns (Address, City, State) Using Substring, Charindex and Parsename.

SELECT PropertyAddress
FROM PortfolioProject..Nashville
--Where PropertyAddress is Null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM PortfolioProject..Nashville

ALTER TABLE PortfolioProject.dbo.Nashville
Add PropertySplitAddress Nvarchar(255);

ALTER TABLE PortfolioProject.dbo.Nashville
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject.dbo.Nashville
SET  PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)
Update PortfolioProject.dbo.Nashville
SET  PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

SELECT OwnerAddress
FROM PortfolioProject..Nashville

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject..Nashville

ALTER TABLE PortfolioProject.dbo.Nashville
Add OwnerSplitAddress Nvarchar(255);

ALTER TABLE PortfolioProject.dbo.Nashville
Add OwnerSplitCity Nvarchar(255);

ALTER TABLE PortfolioProject.dbo.Nashville
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject.dbo.Nashville
SET  OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)
Update PortfolioProject.dbo.Nashville
SET  OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)
Update PortfolioProject.dbo.Nashville
SET  OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

-----------------------------------------------------------------------------------------------------------
--4.Switching "Y" to "Yes" and "N" to "No" to standarize the Column "Sold as Vacant"

Select Distinct (SoldAsVacant), count(SoldAsVacant)
From PortfolioProject.dbo.Nashville
Group by SoldAsVacant

Select SoldAsVacant,
CASE when SoldAsVacant = 'Y' THEN 'Yes'
when SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
From PortfolioProject.dbo.Nashville

Update PortfolioProject.dbo.Nashville
SET  SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
	when SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
 
-----------------------------------------------------------------------------------------------------------
--5.Removing Duplicate 

With RowNumCTE as(
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
ORDER BY UniqueID) as Row_Num

FROM PortfolioProject..Nashville
)

--Select*
--From RowNumCTE
--where Row_Num > 1
--order by PropertyAddress

DELETE
From RowNumCTE
where Row_Num > 1

SELECT * 
FROM PortfolioProject..Nashville
-----------------------------------------------------------------------------------------------------------
--6.Deleting Unused Coumns

Select *
From PortfolioProject.dbo.Nashville
order by [UniqueID ]

ALTER TABLE PortfolioProject.dbo.Nashville
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress



