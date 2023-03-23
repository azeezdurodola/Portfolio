-- Create SQL queries

select *
from NHDC

--Standardize Date format

select Saledateconverted
--convert(Date,Saledate) as NewDate
from NHDC

-- Updating Column

update NHDC 
set Saledate = convert(Date,Saledate)

Alter Table NHDC
Add Saledateconverted date;

update NHDC 
set Saledateconverted = convert(Date,Saledate)

-- Populate PropertyAdrress

select *
from NHDC
--where PropertyAddress is null
order by ParcelID


select A.ParcelID ,A.PropertyAddress, B.PropertyAddress, B.ParcelID ,isnull (A.PropertyAddress,B.PropertyAddress)
from NHDC as A
join NHDC as B
on A.ParcelID = B.ParcelID
and A.UniqueID <> B.UniqueID
where A.PropertyAddress is null

update A
set PropertyAddress = isnull (A.PropertyAddress,B.PropertyAddress)
from NHDC as A
join NHDC as B
on A.ParcelID = B.ParcelID
and A.UniqueID <> B.UniqueID


--breaking out individuals column

select PropertyAddress
from NHDC
--where PropertyAddress is null
--order by ParcelID


Select 
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1 , Len(PropertyAddress)) as NewAddress
from NHDC


Alter Table NHDC
Add Propertysplitaddress nvarchar(255);

update NHDC 
set Propertysplitaddress =SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)


Alter Table NHDC
Add Propertysplitcity  nvarchar(255);

update NHDC 
set Propertysplitcity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1 , Len(PropertyAddress))

select *
from NHDC

select OwnerName
from NHDC


--Seperate columnh
select 
PARSENAME(replace (OwnerName, ',','.'),3),
PARSENAME(replace (OwnerName, ',','.'),2),
PARSENAME(replace (OwnerName, ',','.'),1)

from NHDC


Alter Table NHDC
Add Ownersplitaddress nvarchar(255);

update NHDC 
set Ownersplitaddress =PARSENAME(replace (OwnerName, ',','.'),3)


Alter Table NHDC
Add Ownersplitcity nvarchar(255);

update NHDC 
set Ownersplitcity =PARSENAME(replace (OwnerName, ',','.'),2)

Alter Table NHDC
Add Ownersplitstate nvarchar(255);

update NHDC 
set Ownersplitstate =PARSENAME(replace (OwnerName, ',','.'),1)

select *
from NHDC


--change Y and N to yes and no in soldvsvacant 

select distinct(SoldAsVacant), count(SoldAsVacant)
from NHDC
group by SoldAsVacant
order by SoldAsVacant

select SoldAsVacant,
case	when SoldAsVacant = 'Y' then 'Yes'
		when  SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end
from NHDC

----------------------------------------------------------------------
update NHDC
set SoldAsVacant =
case	when SoldAsVacant = 'Y' then 'Yes'
		when  SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end
-----------------------------------------------------------------

--Remove duplicate
with rownumCTE as(
Select *, 
	Row_Number() Over (
	partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order by
					UniqueID
					) row_num

from NHDC
--order by ParcelID
)
select *
from rownumCTE
where row_num >1
order by PropertyAddress

---------------------------------------------------------------------
Delete
from rownumCTE
where row_num >1
--order by PropertyAddress
-------------------------------------------------------------
--Delecting unused table

select *
from NHDC 

Alter table NHDC
Drop column OwnerAddress,TaxDistrict, PropertyAddress 

Alter table NHDC
Drop column SaleDate