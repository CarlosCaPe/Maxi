CREATE PROCEDURE [Corp].[st_GetPayerFXGrouping]
(
    @IdPayerGroup INT = NULL,
    @IdPayer INT = NULL
)
AS
/********************************************************************
<Author> ??? </Author>
<app> Corporative </app>
<Description>Get Payers to Groups</Description>

<ChangeLog>
<log Date="16/10/2017" Author="snevarez">Get Payers to Groups</log>
</ChangeLog>
*********************************************************************/
BEGIN TRY
    Declare @HasError INT = 0;
    Declare @Message varchar(max) = '';

    IF(@IdPayerGroup = 0)
	   SET @IdPayerGroup = NULL;
	   
    IF(@IdPayer = 0)
	   SET @IdPayer = NULL;

    SELECT
	   PG.IdPayerGroup,
	   PG.PayerGroup,

	   PG.[Active],
	   FX.IdPayerFXGrouping,
	   FX.IdPayerConfig,
	   FX.IdPayer,
	   ISNULL(FX.DateOfLastChange, PG.DateOfLastChange) AS DateOfLastChange,
	   ISNULL(FX.IdUserLastChange, PG.IdUserLastChange) AS IdUserLastChange,

	   P.PayerCode,
	   P.PayerName
    FROM  [dbo].[PayerGroup] AS PG WITH(NOLOCK)
	   LEFT JOIN [dbo].[PayerFXGrouping] AS FX WITH(NOLOCK) ON PG.IdPayerGroup = FX.IdPayerGroup
	   INNER JOIN  [dbo].[Payer] AS P  WITH(NOLOCK) ON FX.IdPayer = P.IdPayer
    WHERE 
		  PG.IdPayerGroup = ISNULL(@IdPayerGroup,PG.IdPayerGroup)
	   AND
		  FX.IdPayer = ISNULL(@IdPayer,FX.IdPayer);

END TRY
BEGIN CATCH
    Set @HasError = 1;
    Declare @ErrorMessage nvarchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_GetPayerFXGrouping',Getdate(),@ErrorMessage);
END CATCH
