
CREATE PROCEDURE [dbo].[st_ValidStateLicensed]

	@StateCode NVARCHAR(MAX),
	@IsValid int OUTPUT
AS
BEGIN		
	
	SELECT TOP 1 @IsValid=SendLicense FROM State WITH(NOLOCK)WHERE StateCode = @StateCode and idcountry=18
	set @IsValid = isnull(@IsValid,0)	

END
