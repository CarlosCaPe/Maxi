CREATE PROCEDURE [Corp].[st_CheckOfacByName]
(
@Name nvarchar (max),
@LastName nvarchar(max),
@SecondLastName nvarchar(max),
@IsValid bit Output
)   
as
Set Nocount on


Declare @ofacResult int 

set @ofacResult= (Select dbo.fun_OfacSearch (@Name,@LastName,''))

If @ofacResult = 1
BEGIN
set @IsValid=1
	EXEC [Corp].[ST_OFAC_SEARCH_DETAILS] @Name,@LastName,''
END
ELSE 
BEGIN
	SET @IsValid=0
END
