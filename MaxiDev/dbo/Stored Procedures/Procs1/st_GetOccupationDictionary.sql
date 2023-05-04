
CREATE PROCEDURE [dbo].[st_GetOccupationDictionary]
AS
BEGIN
	SELECT Name,NameEs FROM [dbo].[DictionaryOccupation]
END
