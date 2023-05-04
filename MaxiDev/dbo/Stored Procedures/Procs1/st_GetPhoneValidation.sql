CREATE PROCEDURE [dbo].[st_GetPhoneValidation]
(
	@CellularNumber    VARCHAR(200),	
	@IsValid		        BIT=NULL OUTPUT
)
AS
BEGIN

	select @IsValid=IsValid from PhoneValidation
     where PhoneNumber=@CellularNumber

	 IF @IsValid !=0 and @IsValid !=1
		SET @IsValid =-1

END