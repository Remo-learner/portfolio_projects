SELECT * 
FROM sheet;

-- DATA CLEANING 
-- standadizing date

SELECT saledate ,convert(date,saledate) as saledate
FROM sheet;

Alter table sheet
alter column saledate date;

update sheet 
set saledate = convert(date,saledate);

-- IF it doesn't work then

Alter table sheet 
Add SaleDateConverted date;

Update sheet 
set saledateconverted = convert(date,saledate);

-- Populating property address nulls

SELECT *
FROM sheet as s1
join sheet as s2 
on s1.parcelID = s2.parcelID
where s1.PropertyAddress is not null and s2.PropertyAddress is null ;

UPDATE s1
SET s1.PropertyAddress = s2.PropertyAddress
FROM sheet as s1
join sheet as s2 
on s1.parcelID = s2.parcelID
where s2.PropertyAddress is not null and s1.PropertyAddress is null;

-- Breaking down the address

SELECT SUBSTRING(propertyaddress,1,CharIndex(',',propertyaddress) - 1 ) as streetAddress,
SUBSTRING(propertyaddress,CHARINDEX(',',propertyaddress) + 1,LEN(propertyaddress) ) as address
FROM sheet;

ALTER table sheet 
add streetAddress varchar(250);

update sheet 
set streetAddress = SUBSTRING(propertyaddress,1,charINDEX(',',propertyaddress) - 1);

ALTER table sheet 
add address varchar(250);

update sheet 
set address = SUBSTRING(propertyaddress,CHARINDEX(',',propertyaddress) + 1,LEN(propertyaddress) );


SELECT parsename(REPLACE(owneraddress,',','.'),3) as streetAddress,
parsename(REPLACE(owneraddress,',','.'),2) as city,
parsename(REPLACE(owneraddress,',','.'),1) as state
FROM sheet;

ALTER table sheet 
add ownerstreetAddress varchar(250);

update sheet 
set  ownerstreetAddress = parsename(REPLACE(owneraddress,',','.'),3);

ALTER table sheet 
add ownercity varchar(250);

update sheet 
set ownercity = parsename(REPLACE(owneraddress,',','.'),2);

ALTER table sheet 
add ownerstate varchar(50);

update sheet 
set ownerstate = parsename(REPLACE(owneraddress,',','.'),1);



SELECT *
FROM sheet
;

-- Replacing Y/N with Yes/NO

SELECT distinct(soldasvacant)
FROM sheet
;

SELECT soldasvacant,
CASE 
	when soldasvacant = 'Y' then 'Yes'
	when soldasvacant = 'N' then 'No'
	Else soldasvacant 
END
FROM sheet
;

update sheet 
set SoldAsVacant = 
CASE 
	when soldasvacant = 'Y' then 'Yes'
	when soldasvacant = 'N' then 'No'
	Else soldasvacant 
END;

-- OR if case statment doesn't work 

Select Replace(soldasvacant,'Yes','Y'),
Replace(soldasvacant,'No','N')
FROM sheet ;

update sheet 
set soldasvacant = 'Y'
where SoldAsVacant like 'Yes';

update sheet 
set soldasvacant = 'N'
where SoldAsVacant like 'No';

update sheet 
set soldasvacant = 'Yes'
where SoldAsVacant like 'Y';

update sheet 
set soldasvacant = 'No'
where SoldAsVacant like 'N';


SELECT distinct(soldasvacant)
FROM sheet
;

-- Checking for duplicates and deleting them

With row_numCte as
(
SELECT *,ROW_NUMBER()
OVER(partition by ParcelID,landuse,propertyaddress,saledate,saleprice,legalreference,
soldasvacant,ownername,owneraddress,totalvalue,yearbuilt order by parcelID) as rownum
From sheet
)
DELETE 
from row_numCte 
where rownum > 1
;

-- Deleting unused columns


SELECT *
FROM sheet
;

ALTER table sheet
drop column propertyaddress,owneraddress,saledateconverted;
