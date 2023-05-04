/********************************************************************
<Author>omurillo</Author>
<app>Corporate Angular</app>
<Description></Description>

<ChangeLog>
<log Date="15/10/2020" Author="esalazar"> Guardar configuracion de parametros de redondeo </log>
</ChangeLog>

*********************************************************************/

CREATE PROCEDURE [Corp].[st_SaveConfigRoundingParameters]
(
     @IdPayer int
    ,@IdPaymentType int
    ,@IdScaleRounding int
	,@IsEnabled bit
    ,@HasError bit out
	,@Message varchar(max) out
)
as

	SET NOCOUNT ON;
	
BEGIN TRY

IF EXISTS (SELECT TOP 1 IdPayerRounding FROM [dbo].[PayerRounding] WITH(NOLOCK) WHERE IdPayer = @IdPayer AND IdPaymentType = @IdPaymentType)
BEGIN

    UPDATE [dbo].[PayerRounding]
           SET 
            [IdScaleRounding] = @IdScaleRounding
		   ,[IsEnabled] = @IsEnabled
		   WHERE IdPayer = @IdPayer AND
           IdPaymentType = @IdPaymentType

END
ELSE
BEGIN
INSERT INTO [dbo].[PayerRounding]
           ([IdPayer]
           ,[IdPaymentType]
           ,[IdScaleRounding]
		   ,[IsEnabled]
           )
     VALUES
           (@IdPayer
           ,@IdPaymentType
           ,@IdScaleRounding
		   ,@IsEnabled
           )

END


    set @HasError=0
	SET @Message ='The configuration was saved successfully'

END TRY
begin catch
    set @HasError=1
	SET @Message ='Error trying to save'
    Declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_SaveConfigRoundingParameters]',Getdate(),@ErrorMessage)
end catch