CREATE PROCEDURE [dbo].[st_FindOwnerById](@IdOwner INT)
AS
/********************************************************************
<Author></Author>
<app>Ares 2.0 Legacy Apis</app>
<Description>This stored is used in method GetById from Owner</Description>

<ChangeLog>
<log Date="26/12/2022" Author="maprado">Se agregan campos IdStateEmission, IdCountryEmission</log>
</ChangeLog>
*********************************************************************/
BEGIN

	SELECT cc.IdOwner, cc.Name, cc.LastName, cc.SecondLastName, cc.Address, cc.City, cc.State, cc.Zipcode, 
	cc.Phone, cc.Cel, cc.Email, cc.SSN, cc.IdType, cc.IdNumber, IdExpirationDate, cc.BornDate, cc.BornCountry, 
	cc.CreationDate, cc.DateOfLastChange, cc.EnterByIdUser, cc.IdStatus, cc.CreditScore, cc.IdCounty, cc.IdStateEmission, cc.IdCountryEmission FROM Owner cc WITH(NOLOCK)
	WHERE cc.IdOwner=@IdOwner;
	
END