-- Retrieve all records from the NashvilleHousing table
select * 
from PortfolioProject.dbo.NashvilleHousing;

-- Standardize the date format by adding a new column and converting SaleDate
alter table NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted = convert(date, SaleDate);

-- Verify the conversion by selecting the new SaleDateConverted column
select SaleDateConverted
from PortfolioProject.dbo.NashvilleHousing;

-- Populate missing PropertyAddress data using corresponding records with the same ParcelID
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.propertyAddress)
from PortfolioProject.dbo.NashvilleHousing as a
join PortfolioProject.dbo.NashvilleHousing as b
on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing as a
join PortfolioProject.dbo.NashvilleHousing as b
on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;

-- Break out the PropertyAddress into individual columns for Address and City
select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing;

select substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
	substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, len(PropertyAddress)) as City
from PortfolioProject.dbo.NashvilleHousing;

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, len(PropertyAddress));

-- Break out the OwnerAddress into separate columns for Address, City, and State
select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing;

select
PARSENAME(Replace(OwnerAddress, ',', '.'), 3) as Address,
PARSENAME(Replace(OwnerAddress, ',', '.'), 2) as City,
PARSENAME(Replace(OwnerAddress, ',', '.'), 1) as State
from PortfolioProject.dbo.NashvilleHousing;

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3);

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2);

alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1);

-- Replace 'Y' and 'N' in the SoldAsVacant column with 'Yes' and 'No'
select distinct SoldAsVacant, count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant;

select SoldAsVacant,
	case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant 
	end
from PortfolioProject.dbo.NashvilleHousing;

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant 
	end;

-- Remove duplicate rows based on ParcelID, PropertyAddress, SaleDate, SalePrice, and LegalReference
With RowNumCTE as (
select *,
	ROW_NUMBER() over(partition by
		ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
		order by UniqueID) as row_num
from PortfolioProject.dbo.NashvilleHousing)
delete
from RowNumCTE
where row_num > 1;

-- Delete unused columns: PropertyAddress, OwnerAddress, and SaleDate
alter table PortfolioProject.dbo.NashvilleHousing
drop column PropertyAddress, OwnerAddress;

alter table PortfolioProject.dbo.NashvilleHousing
drop column SaleDate;

-- Select all records to verify the final table structure
select *
from PortfolioProject.dbo.NashvilleHousing;