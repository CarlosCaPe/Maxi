CREATE PROCEDURE [MaxiMobile].[st_GetCustomerIdentificationInfoByIdTransfer]--27543063,6
(
	 @IdTransfer int 
	,@IdIdentificationType int = null
)
/********************************************************************
<Author> RMacias </Author>
<app> WebApi </app>
<Description> SP para obtener la inforamción de la identificacion de customer, además de regresar si es requerida o no el reverso de la identificación </Description>

<ChangeLog>
<log Date="22/11/2017" Author="RMacias">Creation</log>
</ChangeLog>

<ChangeLog>
<log Date="23/12/2019" Author="sgarcia">modification</log>
<id>#1</id>
<description>se agregó el (max) a la variable ssNumber ya que no estaba mandando los datos bien a la aplicación de Fax Android</description>
</ChangeLog>

*********************************************************************/
as
Begin Try 

	declare @identificationId int
	declare @identificationCountryId int
	declare @idState int

	--#1
	declare @ssNumber nvarchar(max)

	declare @identificationName nvarchar(max)
	declare @identificationExpiration datetime
	declare @identificationNumber nvarchar(max)
	declare @identificacionCountryName nvarchar(max)
	declare @bornDate datetime 
	declare @occupation nvarchar(max)
	declare @occupationDetail nvarchar(max)
	declare @imgFrontRequired bit
	declare @imgRearRequired bit
	declare @imgOtherRequired bit


	select @identificationId = c.IdCustomerIdentificationType, @identificationName = ci.Name, @identificationCountryId = c.IdentificationIdCountry, 
		@identificacionCountryName = co.CountryName, @bornDate = c.BornDate, @identificationExpiration = c.ExpirationIdentification, @occupation = c.Occupation, 
		@occupationDetail = c.OccupationDetail, @identificationNumber = c.IdentificationNumber, @idState = c.IdentificationIdState, @ssNumber = c.SSNumber
	from Customer (nolock) c
		join Transfer (nolock) t on t.IdCustomer = c.IdCustomer
		left join CustomerIdentificationType (nolock) ci on c.IdCustomerIdentificationType = ci.IdCustomerIdentificationType
		left join Country (nolock) co on c.IdentificationIdCountry = co.IdCountry
		left join State (nolock) s on s.StateCode = c.State
	where t.IdTransfer = @IdTransfer
	

	if (@IdIdentificationType is null)
	Begin
	/* FRONTAL */
	select @imgFrontRequired = CAST(
		CASE WHEN EXISTS(select d.* from CustomerIdentificationType (nolock) ci
							join RelationDocumentImageType (nolock) ri on ci.IdCustomerIdentificationType = ri.IdDocumentType
							join DocumentImageType (nolock) d on ri.IdDocumentImageType = d.IdDocumentImageType
							where ci.IdCustomerIdentificationType = @identificationId and d.IdDocumentImageType = 1)
							THEN 1
			ELSE 0 END
		as bit)

	/* REVERSO */
	select @imgRearRequired = CAST(
		CASE WHEN EXISTS(select d.* from CustomerIdentificationType (nolock) ci
							join RelationDocumentImageType (nolock) ri on ci.IdCustomerIdentificationType = ri.IdDocumentType
							join DocumentImageType (nolock) d on ri.IdDocumentImageType = d.IdDocumentImageType
							where ci.IdCustomerIdentificationType = @identificationId and d.IdDocumentImageType = 2)
							THEN 1
			ELSE 0 END
		as bit)
	
	/* OTRO */
	select @imgOtherRequired = CAST(
		CASE WHEN EXISTS(select d.* from CustomerIdentificationType (nolock) ci
							join RelationDocumentImageType (nolock) ri on ci.IdCustomerIdentificationType = ri.IdDocumentType
							join DocumentImageType (nolock) d on ri.IdDocumentImageType = d.IdDocumentImageType
							where ci.IdCustomerIdentificationType = @identificationId and d.IdDocumentImageType = 3)
							THEN 1
			ELSE 0 END
		as bit)

	/* RESULT */

	End

	Else
	Begin
	/* FRONTAL */
	select @imgFrontRequired = CAST(
		CASE WHEN EXISTS(select d.* from CustomerIdentificationType (nolock) ci
							join RelationDocumentImageType (nolock) ri on ci.IdCustomerIdentificationType = ri.IdDocumentType
							join DocumentImageType (nolock) d on ri.IdDocumentImageType = d.IdDocumentImageType
							where ci.IdCustomerIdentificationType = @IdIdentificationType and d.IdDocumentImageType = 1)
							THEN 1
			ELSE 0 END
		as bit)

	/* REVERSO */
	select @imgRearRequired = CAST(
		CASE WHEN EXISTS(select d.* from CustomerIdentificationType (nolock) ci
							join RelationDocumentImageType (nolock) ri on ci.IdCustomerIdentificationType = ri.IdDocumentType
							join DocumentImageType (nolock) d on ri.IdDocumentImageType = d.IdDocumentImageType
							where ci.IdCustomerIdentificationType = @IdIdentificationType and d.IdDocumentImageType = 2)
							THEN 1
			ELSE 0 END
		as bit)
	
	/* OTRO */
	select @imgOtherRequired = CAST(
		CASE WHEN EXISTS(select d.* from CustomerIdentificationType (nolock) ci
							join RelationDocumentImageType (nolock) ri on ci.IdCustomerIdentificationType = ri.IdDocumentType
							join DocumentImageType (nolock) d on ri.IdDocumentImageType = d.IdDocumentImageType
							where ci.IdCustomerIdentificationType = @IdIdentificationType and d.IdDocumentImageType = 3)
							THEN 1
			ELSE 0 END
		as bit)

	/* RESULT */
	End

	select @identificationId as identificationId, @identificationName as identificationName, @identificationCountryId as identificationCountryId, @identificacionCountryName as identificacionCountryName, 
		@identificationExpiration as identificationExpiration, @identificationNumber as identificationNumber, @bornDate as bornDate, @occupation as occupation, @occupationDetail as occupationDetail,
		@imgFrontRequired as imgFrontRequired, @imgRearRequired as imgRearRequired, @imgOtherRequired as imgOtherRequired, @idState as state, @ssNumber as ssNumber

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(MAX)
	SELECT @ErrorMessage = ERROR_MESSAGE()           
	INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)
	VALUES('[MaxiMobile].[st_GetCustomerIdentificationInfoByIdTransfer]',GETDATE(),@ErrorMessage)
END CATCH


