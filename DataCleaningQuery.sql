------------------------------------------------------------
--Standardize Date Format

Select SaleDate2 
FROM Nashville

ALTER TABLE Nashville
Add SaleDate2 Date;

Update Nashville
Set SaleDate2 = CONVERT(date, SaleDate)
------------------------------------------------------------

--Populate Property Address Data

Select * 
FROM DAProject1.dbo.Nashville
ORDER BY ParcelID; -- We have same ParcelID

Select a.PropertyAddress,  b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DAProject1.dbo.Nashville a
JOIN DAProject1.dbo.Nashville b
	ON a.ParcelID = b.ParcelID 
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DAProject1.dbo.Nashville a
JOIN DAProject1.dbo.Nashville b
	ON a.ParcelID = b.ParcelID 
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null;

------------------------------------------------------------
--Breaking out PropertyAddress into Individual Columns (Address, City, State)

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS  Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS  City
FROM Nashville;

-- we need to create two new columns

ALTER TABLE Nashville
Add PropertySplitAddress Nvarchar(255);

Update Nashville
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE Nashville
Add PropertySplitCity Nvarchar(255);

Update Nashville
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
FROM FROM DAProject1.dbo.Nashville;


------------------------------------------------------------
--Using 'PARSENAME' to split OwnerAddress Column 

Select OwnerAddress
FROM DAProject1.dbo.Nashville 

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM DAProject1.dbo.Nashville 



ALTER TABLE Nashville
Add OwnerSplitAddress Nvarchar(255);

Update Nashville
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);


ALTER TABLE Nashville
Add OwnerSplitCity Nvarchar(255);

Update Nashville
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE Nashville
Add OwnerSplitState Nvarchar(255);

Update Nashville
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


Select *
FROM DAProject1.dbo.Nashville 


------------------------------------------------------------
--Change Y,N to YES,NO in SoldAsVacant

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM DAProject1.dbo.Nashville 
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 END
FROM DAProject1.dbo.Nashville 


UPDATE DAProject1.dbo.Nashville 
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 END

--------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SaleDate,
					 SalePrice,
					 LegalReference
					 ORDER BY UniqueID
					 ) row_num
FROM DAProject1.dbo.Nashville 
)


SELECT *
FROM RowNumCTE
WHERE row_num > 1
					
					

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM DAProject1.dbo.Nashville 


ALTER TABLE DAProject1.dbo.Nashville 
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict


ALTER TABLE DAProject1.dbo.Nashville 
DROP COLUMN SaleDate