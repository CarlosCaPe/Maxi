CREATE FUNCTION [dbo].[fn_IsCurrentlyAuthorized] (@IdUser INT, @Module VARCHAR(50), @Option VARCHAR(50), @Action VARCHAR(50))
RETURNS BIT
AS
/********************************************************************
<Author>Not Known</Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="24/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
********************************************************************/
BEGIN

DECLARE @result BIT = 0

	
	
IF EXISTS (SELECT *
			FROM OptionUsers U INNER JOIN
			[dbo].[Option] O ON O.IdOption = U.IdOption INNER JOIN
			Modulo M ON M.IdModule = O.IdModule
			WHERE U.IdUser = @IdUser
			 AND M.Name = @Module
			 AND O.Name = @Option
			 AND U.Action LIKE '%' + @Action + '%')	
BEGIN
	SET @result = 1
END
ELSE
BEGIN
	SET @result = 0
END

	RETURN @result

END

