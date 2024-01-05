--Data Cleaning in an SQL QUERY--



Select *
From PortfolioProjects.dbo.NashvilleHousingData

--Here we want to standardize the sale date. 
--There's a time format on the SaleDate column that shouldn't be there.

Select ConvertedSaleDate, CONVERT(Date,SaleDate) 
From NashvilleHousingData

ALTER TABLE NashvilleHousingData
Add ConvertedSaleDate Date;

Update NashvilleHousingData
SET ConvertedSaleDate = CONVERT(Date, SaleDate)


--Here we want to populate the property address
Select *
From NashvilleHousingData
Where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousingData a
JOIN NashvilleHousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress =  ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousingData a
JOIN NashvilleHousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--Here we separate the address into address, city, state

Select PropertyAddress
From NashvilleHousingData


Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
--The -1 in the CHARINDEX will eliminate the unwanted comma as the -1 goes back one positon

From NashvilleHousingData

ALTER TABLE NashvilleHousingData
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousingData
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select *
From NashvilleHousingData


Select OwnerAddress
From NashvilleHousingData

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as Address,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as City,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as State
From NashvilleHousingData

ALTER TABLE NashvilleHousingData
Add OwnerPropertyAddress Nvarchar(255);

Update NashvilleHousingData
SET OwnerPropertyAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE NashvilleHousingData
Add OwnerCity Nvarchar(255);

Update NashvilleHousingData
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE NashvilleHousingData
Add OwnerState Nvarchar(255);

Update NashvilleHousingData
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);


--Here we want to switch the letters of 'y' and 'n' to 'Yes' and 'No' in the 'Sold as Vacant' Column
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousingData
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
	Case when SoldAsVacant = 'Y' THEN 'Yes'
		when SoldAsVacant = 'N' THEN 'No'
		Else SoldAsVacant
		END
From NashvilleHousingData

Update NashvilleHousingData
SET SoldAsVacant = Case when SoldAsVacant = 'Y' THEN 'Yes'
		when SoldAsVacant = 'N' THEN 'No'
		Else SoldAsVacant
		END

--Here we want to remove duplicate data
WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_number


From NashvilleHousingData
)
Select *
From RowNumCTE
Where row_number > 1
 


--Let's just delete some unused columns we don't need

Select *
From NashvilleHousingData

Alter Table NashvilleHousingData
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress


