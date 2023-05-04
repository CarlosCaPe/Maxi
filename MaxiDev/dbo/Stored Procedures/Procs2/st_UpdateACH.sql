CREATE Procedure [dbo].[st_UpdateACH]
(
    @ACHDate DATE,
    @IdUser INT,
    @IdAgentCollectType INT,
    @IsSpanishLanguage INT,
    @BulkData XML,
    @HasError BIT OUT,
    @Message varchar(max) OUT
)
AS 
/********************************************************************
<Author>--</Author>
<app>---</app>
<Description>---</Description>

<ChangeLog>
<log Date="2023/02/10" Author="jdarellano">Se agregan WITH(NOLOCK) faltantes.</log>
</ChangeLog>
*********************************************************************/
--Declaracion de variables
DECLARE @IdACHSummary int;
DECLARE @ACHAplyDate datetime;
DECLARE @DocHandle int;

--Inicializacion de variables
SET @HasError = 0;
SET @Message = 'Operation Successfull';

--Obtener IdACHSummary y @ACHAplyDate
SELECT @IdACHSummary = IdACHSummary,@ACHAplyDate = ApplyDate FROM dbo.ACHSummary WITH (NOLOCK) WHERE ACHDate = @ACHDate AND IdAgentCollectType = @IdAgentCollectType;

IF @IdACHSummary IS NULL
BEGIN
	 INSERT INTO dbo.ACHSummary VALUES (@ACHDate,GETDATE(),GETDATE(),NULL,@IdUser,@IdAgentCollectType);
	 SET @IdACHSummary = SCOPE_IDENTITY();
END

--Verificar si ya se aplico el cambio
IF @ACHAplyDate IS NOT NULL
BEGIN
    SET @HasError = 1;
    SET @Message = 'Error in saving process';
    RETURN   
END

--Actualizar movimientos
BEGIN TRY
EXEC sp_xml_preparedocument @DocHandle OUTPUT,@BulkData 

--actualizar
UPDATE dbo.ACHMovement
SET Amount = d.Amount,Note = d.note
FROM
(
    SELECT IdAgent,Amount,Note,ISNULL(IsNew,0) IsNew FROM OPENXML (@DocHandle, '/AchCollectionDetails/AchCollectionDetail',2)      
    WITH (      
        IdAgent int,      
        Amount MONEY,
        Note nvarchar(MAX),
        IsNew bit
    ) 
) d
WHERE dbo.ACHMovement.IdACHSummary = @IdACHSummary 
AND dbo.ACHMovement.IdAgent = d.IdAgent 
AND d.IsNew = 0;


--insertar
INSERT INTO dbo.ACHMovement
(IdACHSummary,IdAgent,ReferenceAmount,Amount,Note,AmountByCalendar,AmountByLastDay,AmountByCollectPlan,IsManual)
SELECT @IdACHSummary,d.IdAgent,0,d.Amount,d.Note,0,0,0,1
FROM
(
    Select IdAgent,Amount,Note,ISNULL(IsNew,0) IsNew FROM OPENXML (@DocHandle, '/AchCollectionDetails/AchCollectionDetail',2)      
    WITH (      
        IdAgent int,      
        Amount money,
        Note nvarchar(MAX),
        IsNew bit
    ) 
) d
WHERE d.IsNew = 1;

--select * from maxicollection

UPDATE dbo.ACHSummary SET DateofLastChange = GETDATE(), EnterByIdUser = @IdUser WHERE IdACHSummary = @IdACHSummary;

END TRY
BEGIN CATCH
	Set @HasError = 1;
	SELECT @Message = dbo.GetMessageFromLenguajeResorces(@IsSpanishLanguage,80);
	DECLARE @ErrorMessage nvarchar(MAX);
	SELECT @ErrorMessage = ERROR_MESSAGE();
	INSERT INTO dbo.ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage) VALUES ('st_UpdateACH',Getdate(),@ErrorMessage);
END CATCH