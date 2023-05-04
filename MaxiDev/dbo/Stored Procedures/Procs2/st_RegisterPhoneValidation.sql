CREATE PROCEDURE [dbo].[st_RegisterPhoneValidation]
(
	@IdDialingCodePhoneNumber       INT,
	@IdTelephoneType                INT,
	@PhoneNumber					VARCHAR (20),
	@CreationDate					DATETIME,
	@IsValid						BIT,
	@ValidationDate					DATETIME
)
AS
BEGIN

Insert Into dbo.PhoneValidation(
    IdDialingCodePhoneNumber,
	IdTelephoneType,
	PhoneNumber,
	CreationDate,
	IsValid,
	ValidationDate
)

VALUES(
    @IdDialingCodePhoneNumber,
	@IdTelephoneType,
	@PhoneNumber,
	@CreationDate,
	@IsValid,
	@ValidationDate

);
END