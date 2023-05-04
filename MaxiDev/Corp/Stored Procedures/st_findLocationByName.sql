CREATE PROCEDURE [Corp].[st_findLocationByName](@busqueda VARCHAR(200), @TOP INT = NULL, @idOut INT = NULL OUT  )
AS
/********************************************************************
<Author>Fabian Gonzalez</Author>
<app>Corporate </app>
<Description>Obtiene Pais, Estado a partir de una cadena</Description>

<ChangeLog>
<log Date="14/06/2017" Author="Fgonzalez">Creacion</log>

</ChangeLog>

*********************************************************************/
BEGIN

	IF len(@busqueda)>2 BEGIN

	SET @busqueda = dbo.sf_RemoveExtraChars(replace(@busqueda,',',''))

	DECLARE @compound TABLE (id INT IDENTITY , word VARCHAR(100))

	INSERT INTO @compound (word)
	SELECT item
	FROM dbo.fnSplit(@busqueda,' ') WHERE item NOT IN ('el','la','los','las','de','del')
	DECLARE @compsearch VARCHAR(8000)

	SET @idOut= 0


	SET @compsearch ='"'
	DECLARE @ini INT,@fin INT , @word VARCHAR(200)
	SELECT @ini=1,@fin=count(*) FROM @compound
	WHILE @ini <=@fin BEGIN
	SELECT @word = word FROM @compound WHERE id=@ini
	IF (@word IS NOT NULL) BEGIN
		IF len(@compsearch) > 1 BEGIN
		  SET @compsearch=@compsearch+' AND "'
		END
		SET @compsearch=@compsearch+ltrim(rtrim(isnull(@word,'')))+'*"'
	END
	SET @ini =@ini+1
	END

	DECLARE @ExactMatch TABLE (idLocation INT, rank INT ,idCountry INT , idState INT, idCity INT, LocationName VARCHAR(200))

	INSERT INTO @ExactMatch
	SELECT idLocation,RANK,idCountry, idState, idCity, LocationName FROM  FreeTextTable (location,(LocationName), @busqueda) P
	JOIN [dbo].[Location] L WITH(NOLOCK) ON L.idLocation = p.[KEY]
	WHERE RANK >= 60  ORDER BY Rank DESC


	SELECT @ini=1,@fin=count(*) FROM @compound
	WHILE @ini <=@fin BEGIN
	SELECT @word = word FROM @compound WHERE id=@ini

   	DELETE FROM @ExactMatch WHERE LocationName NOT LIKE '%'+@word+'%'

	SET @ini =@ini+1
	END

	IF @TOP IS NOT NULL AND @TOP > 0
	 SET ROWCOUNT @TOP

	IF NOT EXISTS (SELECT 1 FROM @ExactMatch) BEGIN

		--PRINT 'FullText Match: '+@busqueda

		IF (@top IS NULL or @top > 0)
		SELECT idCountry, idState, idCity, LocationName FROM [dbo].[Location] WITH(NOLOCK) WHERE CONTAINS((LocationName,AL1,AL2,AL3),@compsearch)
		ORDER BY LocationName

		SELECT TOP 1 @idOut = idLocation FROM [dbo].[Location] WITH(NOLOCK) WHERE CONTAINS((LocationName,AL1,AL2,AL3),@compsearch) 	ORDER BY LocationName


	END ELSE BEGIN
		--PRINT 'Exact Match: '+@busqueda
		IF (@top IS NULL or @top > 0)
		SELECT idCountry, idState, idCity, LocationName FROM @ExactMatch ORDER BY rank DESC ,idLocation ASC

		SELECT TOP 1 @idOut = idLocation FROM @ExactMatch ORDER BY rank DESC, idLocation ASC
	END
	END
END

