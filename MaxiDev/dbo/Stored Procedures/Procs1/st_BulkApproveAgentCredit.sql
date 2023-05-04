
CREATE PROCEDURE [dbo].[st_BulkApproveAgentCredit]
(
    @AgentApprovalsData XML,
    @IsApprove bit,    
    @IdUser INT,
    @IsSpanishLanguage INT,    
    @HasError BIT OUT,
    @MessageOut varchar(max) OUT
)
AS
--Declaracion de variables
DECLARE @DocHandle INT 
DECLARE @IdAgentApproval int
DECLARE @IdAgent int 
DECLARE @CreditLimitSuggested money

--Inicializar Variables
Set @HasError=0
Select @MessageOut = dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,79)   

BEGIN TRY
EXEC sp_xml_preparedocument @DocHandle OUTPUT,@AgentApprovalsData 

Create Table #CreditApproval
(    
    IdAgentApproval INT   
)

--Guardar informacion de Creditos en tabla temporal
INSERT INTO #CreditApproval
SELECT value From OPENXML (@DocHandle, '/root/value',2) 
    WITH (      
        value INT 'text()'
    )

--SELECT * From OPENXML (@DocHandle, '/root',2) 
--SELECT * FROM #CreditApproval

delete from #CreditApproval where isnull(IdAgentApproval,0)=0

While exists (Select top 1 1 from #CreditApproval)      
BEGIN
    Select top 1 @IdAgentApproval=IdAgentApproval from #CreditApproval
    
    update AgentCreditApproval set EnterByIdUser=@IdUser, DateOfLastChange=getdate(), IsApproved=@IsApprove, @CreditLimitSuggested=round(CreditLimitSuggested,2) , @IdAgent=IdAgent  where IdAgentCreditApproval=@IdAgentApproval
    
    if (@IsApprove=1)
    begin
        exec st_SaveAgentMirror @IdAgent 
        update agent set creditamount=@CreditLimitSuggested,dateoflastchange=getdate(), enterbyiduser=@IdUser  where idagent=@IdAgent

        Declare @HasErrorLH bit

       EXEC	 [dbo].[st_SaveAgentCreditLimitHistory]
		    @IdAgent = @IdAgent,   
		    @CreditLimitSuggested = @CreditLimitSuggested,
		    @EnterbyIdUser = @IdUser,
		    @HasError = @HasErrorLH OUTPUT
    end

    --SELECT @IdAgentApproval
    
    Delete #CreditApproval where IdAgentApproval=@IdAgentApproval
END    

END TRY
BEGIN CATCH
 Set @HasError=1                                                                                   
 Select @MessageOut = dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,80)                                                                               
 Declare @ErrorMessage nvarchar(max)                                                                                             
 Select @ErrorMessage=ERROR_MESSAGE()                                             
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_BulkApproveAgentCredit',Getdate(),@ErrorMessage)    
END CATCH
