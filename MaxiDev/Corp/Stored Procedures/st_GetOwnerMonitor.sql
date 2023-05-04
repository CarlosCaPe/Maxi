CREATE PROCEDURE  [Corp].[st_GetOwnerMonitor] 
	@idOwner int
	as
BEGIN
	
	SET NOCOUNT ON;

	SELECT 
	   [IdOwner]
      ,[Name]
      ,[LastName]
      ,[SecondLastName]
      ,[IdStatus]
	  FROM [dbo].[Owner] with (nolock)
	WHERE IdOwner=@idOwner
END
