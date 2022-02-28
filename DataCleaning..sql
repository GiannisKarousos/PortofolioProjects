--Cleaning housing data in SQL

--Checking the dataset
SELECT * 
FROM PortofolioProject..NashvilleHousing

--Seperate SaleDate

SELECT saleDateConverted, CONVERT(Date,SaleDate)
FROM PortofolioProject..NashvilleHousing

--Σπάσιμο
UPDATE PortofolioProject..NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

--Extra στήλη
ALTER TABLE PortofolioProject..NashvilleHousing
ADD saleDateConverted Date;

UPDATE PortofolioProject..NashvilleHousing
SET saleDateConverted = CONVERT(Date,SaleDate)

-- Populate Propery Address Data, If ParcellID=ParcellID then propertyAddress=propertyAddress

SELECT *
FROM PortofolioProject..NashvilleHousing
--WHERE propertyAddress IS NULL
ORDER BY ParcelID

--Joining the same table using dif unique id 
--to fill the nulls in the  a.propertyAddress with the info from b.propertyAddress

SELECT a.ParcelID, a.propertyAddress, b.ParcelID, b.propertyAddress, ISNULL(a.propertyAddress, b.propertyAddress)
FROM PortofolioProject..NashvilleHousing a
JOIN PortofolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID] --not the same row
WHERE a.propertyAddress IS NULL

UPDATE a
SET propertyAddress = ISNULL(a.propertyAddress, b.propertyAddress)
FROM PortofolioProject..NashvilleHousing a
JOIN PortofolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID] 
WHERE a.propertyAddress IS NULL

--Creating seperate col (Address, City, State)

SELECT PropertyAddress
FROM PortofolioProject..NashvilleHousing

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1), LEN(PropertyAddress) AS Address
FROM PortofolioProject..NashvilleHousing

ALTER TABLE PortofolioProject..NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE PortofolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE PortofolioProject..NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE PortofolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1), LEN(PropertyAddress)


--Seperate OwnerAddress (another way-recommended-easiest)

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortofolioProject..NashvilleHousing

--adding col to table
ALTER TABLE PortofolioProject..NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

--setting the split I want in the new col
UPDATE PortofolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE PortofolioProject..NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE PortofolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE PortofolioProject..NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE PortofolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


--Change Y, N to Yes, No in Sold as Vacant col

SELECT DISTINCT(SoldAsVacant),  COUNT(SoldAsVacant)
FROM PortofolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2



SELECT SoldAsVacant, CASE	WHEN SoldAsVacant = 'Y' THEN 'Yes'
							WHEN SoldAsVacant = 'N' THEN 'No'
							ELSE SoldAsVacant
							END
FROM PortofolioProject..NashvilleHousing

UPDATE PortofolioProject..NashvilleHousing
SET SoldAsVacant = CASE	WHEN SoldAsVacant = 'Y' THEN 'Yes'
							WHEN SoldAsVacant = 'N' THEN 'No'
							ELSE SoldAsVacant
							END

--Delete Unused Col

SELECT *
FROM PortofolioProject..NashvilleHousing

ALTER TABLE PortofolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate