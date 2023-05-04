
CREATE PROCEDURE st_RefreshLocations
AS 
/********************************************************************
<Author>Fabian Gonzalez</Author>
<app>Agent, Corp</app>
<Description>Actualiza tabla de ubicaciones con registros faltantes o modificados</Description>

<ChangeLog>
<log Date="16/06/2017" Author="Fgonzalez"> Creacion </log>

</ChangeLog>

*********************************************************************/
BEGIN 


--Se insertan ciudades, estados y paises faltantes en el catalogo de ubicaciones.
INSERT INTO Location (idCountry, IdState, IdCity, LocationName)
SELECT c.idCountry,s.IdState,t.IdCity, t.CityName+', '+s.StateName+', '+c.CountryName AS Location
FROM Country c
JOIN State s ON s.IdCountry = c.idCountry
JOIN City t ON t.IdState = s.IdState
WHERE NOT EXISTS (SELECT 1 FROM Location l WHERE l.idCountry = c.idCountry AND l.idState = s.idState AND l.idCity = t.idCity)

--Se obtiene el listado de cambios en estados , ciudades y paises existentes
SELECT c.idCountry,s.IdState,t.IdCity,LName=t.CityName+', '+s.StateName+', '+c.CountryName 
INTO #tmpUpdLocations
FROM Country c
JOIN State s ON s.IdCountry = c.idCountry
JOIN City t ON t.IdState = s.IdState
LEFT JOIN Location loc
ON loc.idCountry = c.IdCountry AND loc.idState = s.IdState AND loc.idCity= t.IdCity AND loc.LocationName=(t.CityName+', '+s.StateName+', '+c.CountryName)
WHERE loc.idLocation IS NULL 

CREATE NONCLUSTERED INDEX Ix1_TmpUpdLocations ON #tmpUpdLocations(idCountry,idState,idCity)

--Se actualiza en location el nombre de lo nuevo
UPDATE x
SET LocationName =  z.LName
FROM Location x
JOIN #tmpUpdLocations z 
ON z.idCountry=x.idCountry 
AND z.idState = x.idState 
AND z.idCity = x.idCity


UPDATE Location
SET  AL1 = replace(replace(LocationName,'X','J'),'MEJICO','MEXICO')
	,AL2 =replace(replace(LocationName,'X','S'),'MESICO','MEXICO')
	,AL3 =replace(replace(LocationName,'X','Z'),'MEZICO','MEXICO')
WHERE LocationName LIKE '%X%'

END 
