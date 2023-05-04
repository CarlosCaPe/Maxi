CREATE PROCEDURE [Corp].[st_UpdateACH]
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
--Declaracion de variables
DECLARE @IdACHSummary INT
DECLARE @ACHAplyDate DATETIME
DECLARE @DocHandle INT 


--Inicializacion de variables
SET @HasError=0
SET @Message='Operation Successfull'

--Obtener IdACHSummary y @ACHAplyDate
SELECT @IdACHSummary=IdACHSummary,@ACHAplyDate=ApplyDate FROM dbo.ACHSummary WITH(NOLOCK) WHERE ACHDate=@ACHDate AND IdAgentCollectType=@IdAgentCollectType

IF @IdACHSummary IS NULL
BEGIN

	 INSERT dbo.ACHSummary VALUES (@ACHDate,GETDATE(),GETDATE(),NULL,@IdUser,@IdAgentCollectType)
	 SET @IdACHSummary=SCOPE_IDENTITY ()

END

--Verificar si ya se aplico el cambio
IF @ACHAplyDate IS NOT NULL
BEGIN

    SET @HasError=1
    SET @Message= 'Error in saving process ddg' 
    RETURN   
END

--Actualizar movimientos
BEGIN TRY
EXEC sp_xml_preparedocument @DocHandle OUTPUT,@BulkData 

--actualizar
UPDATE dbo.ACHMovement
SET amount=d.Amount,note=d.note
FROM
(
    Select IdAgent,Amount,Note,isnull(IsNew,0) IsNew From OPENXML (@DocHandle, '/AchCollectionDetails/AchCollectionDetail',2)      
    WITH (      
        IdAgent int,      
        Amount MONEY,
        Note NVARCHAR(max),
        IsNew bit
    ) 
) d
WHERE 
    dbo.ACHMovement.IdACHSummary=@IdACHSummary and
    dbo.ACHMovement.IdAgent=d.IdAgent and
    d.IsNew=0


--insertar
insert into ACHMovement
(IdACHSummary,IdAgent,ReferenceAmount,Amount,Note,AmountByCalendar,AmountByLastDay,AmountByCollectPlan,IsManual)
select @IdACHSummary,d.IdAgent,0,d.Amount,d.Note,0,0,0,1
FROM
(
    Select IdAgent,Amount,Note,isnull(IsNew,0) IsNew From OPENXML (@DocHandle, '/AchCollectionDetails/AchCollectionDetail',2)      
    WITH (      
        IdAgent int,      
        Amount MONEY,
        Note NVARCHAR(max),
        IsNew bit
    ) 
) d
WHERE     
    d.IsNew=1

--select * from maxicollection

UPDATE dbo.ACHSummary SET DateofLastChange=GETDATE(), EnterByIdUser=@IdUser WHERE IdACHSummary=@IdACHSummary

END TRY
BEGIN CATCH
 Set @HasError=1                                                                                   
 Select @Message = dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,80)                                                                               
 Declare @ErrorMessage nvarchar(max)                                                                                             
 Select @ErrorMessage=ERROR_MESSAGE()                                             
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_UpdateACH',Getdate(),@ErrorMessage)    
END CATCH
