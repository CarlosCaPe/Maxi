
CREATE PROCEDURE [dbo].[st_ApplyCalendarCollection]
(
    @IdCalendarCollect INT,
    @IdUser INT,
    @IsSpanishLanguage bit, 
    @HasError bit out,
    @Message varchar(max) out    
)
AS
--Declaracion de variables
DECLARE @Amount MONEY
DECLARE @IdAgent MONEY
DECLARE @IdAgentCollection INT
DECLARE @LastAmountToPay money 
DECLARE @ActualAmountToPay money
DECLARE @Date DATETIME
declare @fee money

--Inicializacion de variables
SELECT 
        @HasError=0,
        @Message='Operation Succesfull'        

BEGIN TRY        
--Obtener datos de calendarcollect
SELECT 
    @Amount=Amount,  --Obtener monto
    @fee=a.Fee,
    @IdAgent=c.IdAgent, --ObtenerAgencia
    @IdAgentCollection = a.IdAgentCollection
FROM
    dbo.CalendarCollect c WITH(NOLOCK)
JOIN
    AgentCollection a WITH(NOLOCK) ON a.IdAgent=c.IdAgent
WHERE 
    IdCalendarCollect=@IdCalendarCollect

IF (ISNULL(@IdAgent,0)>0)
BEGIN
    --Actualizar adeudo del agente
    UPDATE AgentCollection 
        SET 
            DateofLastChange=GETDATE(), 
            EnterByIdUser=@IdUser, 
            AmountToPay=AmountToPay-@Amount,
            fee = case when AmountToPay-@Amount=0 then 0 else fee end
    WHERE 
        IdAgent=@IdAgent
    --Afectar Balance CGO por Calendar Collect
    --cambiar
  --  EXEC [dbo].[st_OPDebitCreditToAgentBalance]
		--@IdAgent,
		--@Amount,
		--@IdCalendarCollect,
		--@IdCalendarCollect,
		--N'Charge for Calendar Collection', --Description
		--0,          --Commision
		--N'CGO',     --OperationType
		--'Credit',   --Credit
		--0,          --CGS
		--0,          --Fee
		--0,          --ProviderFee 
		--0           --CorpCommission

		DECLARE @SaveDebNote NVARCHAR(MAX)
		IF @fee > 0
			SET @SaveDebNote = '4407-31 Deferred Plan Fee - Period'
		ELSE
			SET @SaveDebNote = 'Transfer From Deferred Balance'

        SELECT @date= GETDATE()
        EXEC [dbo].[st_SaveDeb]
		@IsSpanishLanguage,
		@IdAgent,
		@Amount,
		1,      --IsDebit=
		@date,
		@SaveDebNote, --N'Transfer From Deferred Balance',
		'',--@IdCalendarCollect,
		@IdUser,
		@HasError OUTPUT,
		@Message OUTPUT,
        10,--10	Collection Plan Transfer – (Charge by Calendar Collection)
        null

		SELECT @date= DATEADD (second , 1 , @date)

        if (@fee>0)
        begin
            EXEC [dbo].[st_SaveOtherCharge]
		        @IsSpanishLanguage,
		        @IdAgent,
		        @fee,
		        1,      --IsDebit=
		        @date,
		        '', --N'', --'4407-31 Deferred Plan Fee - Period', --N'',
		        '',--@IdCalendarCollect,
		        @IdUser,
		        @HasError OUTPUT,
		        @Message OUTPUT,
                24, -- 11,--11	Collection Plan Fee – (Fee by Calendar Collection)
                null
        end

    --Obtener ultimo adeudo
    SELECT TOP 1 @ActualAmountToPay=ActualAmountToPay FROM dbo.AgentCollectionDetail WITH(NOLOCK) WHERE IdAgentCollection=@IdAgentCollection ORDER BY IdAgentCollectiondetail desc
    SET @ActualAmountToPay = ISNULL(@ActualAmountToPay,0)

    --Calcular Montos
    SET @LastAmountToPay = @ActualAmountToPay
    SET @ActualAmountToPay = @ActualAmountToPay-@Amount

	DECLARE @CollectionDetailNote NVARCHAR(MAX)
	IF @fee > 0
		SET @CollectionDetailNote = '4407-31 Deferred Plan Fee - Period'
	ELSE
		SET @CollectionDetailNote = 'Transfer To Current Balance'

    INSERT INTO [dbo].[AgentCollectionDetail]
        ([IdAgentCollection]
        ,[LastAmountToPay]
        ,[ActualAmountToPay]
        ,[AmountToPay]
        ,[Note]
        ,[IdAgentCollectionConcept]
        ,[CreationDate]
        ,[DateofLastChange]
        ,[EnterByIdUser])
    VALUES
        (@IdAgentCollection
        ,@LastAmountToPay
        ,@ActualAmountToPay
        ,@Amount
        ,@CollectionDetailNote --,'Transfer To Current Balance'
        ,3 --@IdAgentCollectionConcept --Consolidated
        ,GETDATE()
        ,GETDATE()
        ,@IdUser) 

    --Eliminar pago
    DELETE FROM dbo.CalendarCollect WHERE IdCalendarCollect=@IdCalendarCollect
END

--    SELECT * FROM AgentCollection
END TRY
BEGIN CATCH
 Set @HasError=1                                                                                   
 Select @Message = dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,80)                                                                               
 Declare @ErrorMessage nvarchar(max)                                                                                             
 Select @ErrorMessage=ERROR_MESSAGE()                                             
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_ApplyCalendarCollection',Getdate(),@ErrorMessage)    
END CATCH
