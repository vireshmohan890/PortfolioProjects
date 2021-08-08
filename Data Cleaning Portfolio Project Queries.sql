

SELECT * FROM PortfolioProject..NashvilleHousing

-- Editing Sale date


SELECT SaleDate, FROM PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE PortfolioProject..NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)

SELECT  SaleDateConverted 
FROM PortfolioProject..NashvilleHousing



-- Populating PropertyAddress Data


SELECT  A.PropertyAddress, A.[UniqueID ], A.ParcelID, B.PropertyAddress, B.ParcelID,
ISNULL(A.PropertyAddress,  B.PropertyAddress)
FROM PortfolioProject..NashvilleHousing A
JOIN PortfolioProject..NashvilleHousing B
ON A.ParcelID= B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
--WHERE A.PropertyAddress IS NULL

UPDATE A
SET A.PropertyAddress = ISNULL(A.PropertyAddress,  B.PropertyAddress)
FROM PortfolioProject..NashvilleHousing A
JOIN PortfolioProject..NashvilleHousing B
ON A.ParcelID= B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL



-- Breaking out Addrr into (Addr, City, State)


SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing

SELECT SUBSTRING( PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING( PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City

FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING( PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertyCity nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET PropertyCity = SUBSTRING( PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


SELECT PropertySplitAddress, PropertyCity
FROM PortfolioProject..NashvilleHousing



-- Now separating address from OwnerAddress into address, city and State using PARSENAME
-- PARSENAME only recognises periods(.). So, we will have to replace commas with periods


SELECT OwnerAddress 
FROM PortfolioProject..NashvilleHousing

SELECT 
PARSENAME( REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME( REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME( REPLACE(OwnerAddress, ',', '.') , 1)
FROM PortfolioProject..NashvilleHousing;


ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME( REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerCity nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerCity = PARSENAME( REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerState nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerState = PARSENAME( REPLACE(OwnerAddress, ',', '.') , 1)


SELECT OwnerSplitAddress, OwnerCity, OwnerState
FROM PortfolioProject..NashvilleHousing



--Change Y and N to Yes and No in SoldAsVacant
-- We can also use case statement instead of below approach


SELECT DISTINCT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = 'Yes' WHERE SoldAsVacant = 'Y'

UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = 'No' WHERE SoldAsVacant = 'N'



-- Removing Duplicates


WITH Row_NumCTE
AS(

SELECT *,
ROW_NUMBER() OVER ( 
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY UniqueID) AS row_num

FROM PortfolioProject..NashvilleHousing 
--ORDER BY ParcelID
)

DELETE  
FROM Row_NumCTE WHERE row_num>1


--Removing Unused Data


SELECT * 
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN   PropertyAddress
            