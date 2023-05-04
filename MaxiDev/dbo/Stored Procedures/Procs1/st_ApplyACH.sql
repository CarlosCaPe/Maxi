
CREATE Procedure [dbo].[st_ApplyACH]
(
    @ACHDate DATE,
    @IdUser INT,
    @IdAgentCollectType  INT,
    @IsSpanishLanguage INT,    
    @HasError BIT OUT,
    @Message varchar(max) OUT
)
AS 
--Declaracion de variables
DECLARE @IdACHSummary INT
DECLARE @IdACHMovement int
DECLARE @ACHAplyDate DATETIME
DECLARE @DocHandle INT 
DECLARE @IdAgent INT
DECLARE @Amount MONEY
DECLARE @BankName nvarchar(max)
DECLARE @Note nvarchar(max)
Create Table #ACH
(
    IdACHMovement INT,    
    IdAgent INT,
    Amount MONEY,
    referenceamount money,
    ismanual bit,
    BankName nvarchar(max),
    Note nvarchar(max)
)  

--Inicializacion de variables
SET @HasError=0
SET @Message='Operation Successfull'

--Obtener IdACHSummary y @ACHAplyDate
SELECT @IdACHSummary=IdACHSummary,@ACHAplyDate=ApplyDate FROM dbo.ACHSummary WHERE ACHDate=@ACHDate AND IdAgentCollectType=@IdAgentCollectType

IF @IdACHSummary IS NULL
BEGIN

 INSERT dbo.ACHSummary VALUES (@ACHDate,GETDATE(),GETDATE(),NULL,@IdUser,@IdAgentCollectType)
 SET @IdACHSummary=SCOPE_IDENTITY ()

END

--Verificar si ya se aplico el cambio
IF @ACHAplyDate IS NOT NULL
BEGIN
    SET @HasError=1
    SET @Message= 'Error in saving process' 
    RETURN   
END

UPDATE dbo.ACHSummary SET ApplyDate=GETDATE(), EnterByIdUser=@IdUser WHERE IdACHSummary=@IdACHSummary   

--Guardar en una tabla temporal los movimientos a aplicar
INSERT INTO #ACH
SELECT IdACHMovement,m.idagent,amount,referenceamount,ismanual,ISNULL(b.bankname,'') bankname,m.Note 
    FROM dbo.ACHMovement m
JOIN 
    agent a ON m.idagent=a.idagent
LEFT JOIN agentbankdeposit b ON a.IdAgentBankDeposit=b.IdAgentBankDeposit
LEFT JOIN(
    SELECT Idagent,SUM(Amount) OtherAmount FROM dbo.AgentDeposit 
    WHERE  
        dateoflastchange>=@ACHDate AND dateoflastchange<DATEADD(day,1,@ACHDate)
        and 
        (
            (1=2 and isnull(IdAgentCollectType,0) not in (2)) or
            (1=1 and isnull(IdAgentCollectType,0) not in (1))
        )
        and Amount>0
    GROUP BY 
        IdAgent
	) d ON a.IdAgent=d.Idagent
WHERE IdACHSummary=@IdACHSummary AND (ReferenceAmount>ISNULL(d.OtherAmount,0)) and ismanual=0
UNION ALL
SELECT IdACHMovement,m.idagent,amount,referenceamount,ismanual,ISNULL(b.bankname,'') bankname,m.Note 
    FROM dbo.ACHMovement m
JOIN 
    agent a ON m.idagent=a.idagent
LEFT JOIN agentbankdeposit b ON a.IdAgentBankDeposit=b.IdAgentBankDeposit
WHERE IdACHSummary=@IdACHSummary AND ismanual=1

BEGIN TRY
    DECLARE @HasErrorTmp BIT
    DECLARE @MessageTmp  varchar(max)
    DECLARE @Date DATETIME
    DECLARE @ReferenceAmount money
    DECLARE @ismanual bit
    declare @OtherDeposit money = 0
	declare @DateDeposit datetime
    
    --Ciclo para aplicar los movimientos
    While exists (Select top 1 1 from #ACH)      
    Begin      
        Select top 1 @IdACHMovement=IdACHMovement, @IdAgent=IdAgent, @Amount=Amount, @ReferenceAmount=ReferenceAmount, @ismanual=ismanual, @Date = GETDATE(), @BankName=BankName,@Note=Note from #ACH    

		if @IdAgentCollectType=1
		begin
			EXEC [st_SaveDeposit] 
				@IsSpanishLanguage,
				@IdAgent,
				@BankName,
				@Amount,
				@Date,
				@Note,--@IdACHMovement,
				@IdUser,
				@IdAgentCollectType, --Type ACH Deposit
				@HasErrorTmp OUT,
				@MessageTmp OUT
        end
        else
        begin 			
			if @ismanual=1 
            begin
				EXEC [st_SaveDeposit] 
				@IsSpanishLanguage,
				@IdAgent,
				@BankName,
				@Amount,
				@Date,
				@Note,--@IdACHMovement,
				@IdUser,
				@IdAgentCollectType, --Type ACH Deposit
				@HasErrorTmp OUT,
				@MessageTmp OUT
			end
			else
				begin                  			
                		
					set @DateDeposit = @ACHDate
                    set @OtherDeposit = 0
					
					select @OtherDeposit=isnull(OtherAmount,0) from
					(

						SELECT Idagent,SUM(Amount) OtherAmount  FROM dbo.AgentDeposit 
						WHERE  
							dateoflastchange>=@DateDeposit AND dateoflastchange<@DateDeposit+1 
							and 
							(
								isnull(IdAgentCollectType,0) not in (2)								
							)
                            and idagent=@IdAgent
							--and Amount>0         
						GROUP BY 
							IdAgent
                    )t

                    set @OtherDeposit=isnull(@OtherDeposit,0)
                    --select @OtherDeposit,@ReferenceAmount 
                    
					if (round(@OtherDeposit,2)<round(@ReferenceAmount,2)) --and @IdAgent=1281 
					begin
						EXEC [st_SaveDeposit] 
						@IsSpanishLanguage,
						@IdAgent,
						@BankName,
						@Amount,
						@Date,
						@Note,--@IdACHMovement,
						@IdUser,
						@IdAgentCollectType, --Type ACH Deposit
						@HasErrorTmp OUT,
						@MessageTmp OUT
					end
				end
        end
        
    
        Delete #ACH where IdACHMovement=@IdACHMovement      
    END
  
    --UPDATE dbo.ACHSummary SET ApplyDate=GETDATE(), EnterByIdUser=@IdUser WHERE IdACHSummary=@IdACHSummary   

END TRY
BEGIN CATCH
 UPDATE dbo.ACHSummary SET ApplyDate=null, EnterByIdUser=@IdUser WHERE IdACHSummary=@IdACHSummary
 Set @HasError=1                                                                                   
 Select @Message = dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,80)                                                                               
 Declare @ErrorMessage nvarchar(max)                                                                                             
 Select @ErrorMessage=ERROR_MESSAGE()                                             
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_ApplyACH',Getdate(),@ErrorMessage)    
END CATCH