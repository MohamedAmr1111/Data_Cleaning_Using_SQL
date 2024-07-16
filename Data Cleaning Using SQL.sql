/*
Cleaning data in sql queries
*/

select *
from PortfolioProject.dbo.NashvilleHousing

---------------------------------------------------------------------------

--Standarize date format

select saleDateConverted , convert(Date , SaleDate)
from PortfolioProject.dbo.NashvilleHousing

alter table NashvilleHousing
add saleDateConverted Date;

update NashvilleHousing
set saleDateConverted = convert(Date,SaleDate)

---------------------------------------------------------------------------

-- Populate Property Address Date

select *
from PortfolioProject.dbo.NashvilleHousing
order by ParcelID


select a.ParcelID , b.ParcelID , a.PropertyAddress , b.PropertyAddress , 
ISNULL(a.PropertyAddress , b.PropertyAddress) 
from PortfolioProject.dbo.NashvilleHousing a 
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null

update a 
set PropertyAddress = ISNULL(a.PropertyAddress , b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a 
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null

---------------------------------------------------------------------------

-- Breakig out address into individual columns (address ,city ,state)

select PropertyAddress ,
Left(PropertyAddress,CHARINDEX(',',PropertyAddress)-1) as address,
LTRIM(RIGHT(PropertyAddress, LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress))) AS city
from PortfolioProject.dbo.NashvilleHousing

Alter table NashvilleHousing
add propertySplitCity Nvarchar(255);

update NashvilleHousing
set propertySplitCity = LTRIM(RIGHT(PropertyAddress, LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress))) 

-- check step
select propertySplitCity
from PortfolioProject.dbo.NashvilleHousing

Alter table NashvilleHousing
add propertySplitAddress Nvarchar(255);

update NashvilleHousing
set propertySplitAddress = Left(PropertyAddress,CHARINDEX(',',PropertyAddress)-1)


--check step
select propertySplitAddress
from PortfolioProject.dbo.NashvilleHousing


select OwnerAddress , 
LEFT(OwnerAddress, CHARINDEX(',', OwnerAddress) - 1) AS address,
SUBSTRING(
        OwnerAddress,
        CHARINDEX(',', OwnerAddress) + 2,
        CHARINDEX(',', OwnerAddress, CHARINDEX(',', OwnerAddress) + 1) - CHARINDEX(',', OwnerAddress) - 2
    ) AS city,
LTRIM(RIGHT(OwnerAddress, CHARINDEX(',', REVERSE(OwnerAddress)) - 1)) AS state
from PortfolioProject.dbo.NashvilleHousing

alter table NashvilleHousing
add ownerSplitAddress Nvarchar(255)

update NashvilleHousing
set ownerSplitAddress = LEFT(OwnerAddress, CHARINDEX(',', OwnerAddress) - 1)

select ownerSplitAddress
from PortfolioProject.dbo.NashvilleHousing

alter table NashvilleHousing
add ownerSplitCity Nvarchar(255)

update NashvilleHousing
set ownerSplitCity = SUBSTRING(
        OwnerAddress,
        CHARINDEX(',', OwnerAddress) + 2,
        CHARINDEX(',', OwnerAddress, CHARINDEX(',', OwnerAddress) + 1) - CHARINDEX(',', OwnerAddress) - 2
    )

select ownerSplitCity
from PortfolioProject.dbo.NashvilleHousing

alter table NashvilleHousing
add ownerSplitState Nvarchar(255)

update NashvilleHousing
Set ownerSplitState = LTRIM(RIGHT(OwnerAddress, CHARINDEX(',', REVERSE(OwnerAddress)) - 1))

select ownerSplitState
from PortfolioProject.dbo.NashvilleHousing

----------------------------------------------------------------------------------------------

-- change Y and N to YES and NO in "Sold as Vacant" fields

select Distinct(SoldAsVacant) , count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant 
order by 2

select SoldAsVacant,
Case when SoldAsVacant = 'Y' Then 'Yes'
	 when SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant 
	 END as Newone
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant = Case when SoldAsVacant = 'Y' Then 'Yes'
	 when SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant 
	 END

--------------------------------------------------------------------------

-- Remove duplicates 

with RowNumCTE as(
select * ,
ROW_NUMBER() over (
Partition by ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 order by uniqueID
			 ) row_num
from PortfolioProject.dbo.NashvilleHousing
)

Delete 
from RowNumCTE
where row_num > 1

-- to check 
--select * 
--from RowNumCTE
--where row_num > 1
--order by propertyAddress

---------------------------------------------------------------------------------------

-- Delete Unused Columns
select *
from PortfolioProject.dbo.NashvilleHousing

Alter table PortfolioProject.dbo.NashvilleHousing
drop column OwnerAddress , TaxDistrict , PropertyAddress,SaleDate

