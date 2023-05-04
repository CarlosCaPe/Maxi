
CREATE PROCEDURE [dbo].[st_SaveOtherChargeReverse]
(    
    @IdAgentOtherCharge INT,    
    @IdLenguage INT,
    @EnterByIdUser INT,
    @HasError BIT OUT,                                  
    @Message NVARCHAR(MAX) OUT
)
AS
DECLARE @Amount MONEY
DECLARE @Notes NVARCHAR(MAX)
DECLARE @DebitOrCredit INT
DECLARE @idotherchargesmemo INT
DECLARE @IdAgent INT
DECLARE @DateOfMovement DATETIME
DECLARE @OtherChargesMemoNote NVARCHAR(MAX)
DECLARE @IsReverseOfReverse BIT

BEGIN TRY

IF EXISTS (SELECT TOP 1 1 FROM [dbo].[ReverseAgentOtherCharge] (NOLOCK) WHERE [IdAgentOtherCharge]=@IdAgentOtherCharge)
BEGIN
 SET @HasError=1                                                     
 SET @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE17')
 RETURN
END

SELECT
    @DateOfMovement = GETDATE(),  
    @IdAgent = O.[IdAgent],
    @Amount = O.[Amount],
    @Notes= CASE WHEN O.[IsReverse] IS NULL OR O.[IsReverse] <> 1 THEN ISNULL([OCM].[Memo],'') ELSE ISNULL(OCM.[ReverseNote],'') END,
    @DebitOrCredit = CASE WHEN B.[DebitOrCredit]='Debit' THEN 0 ELSE 1 END,
    @idotherchargesmemo = O.[IdOtherChargesMemo],
    @OtherChargesMemoNote = O.[OtherChargesMemoNote],
	@IsReverseOfReverse = CASE WHEN O.[IsReverse] IS NULL OR O.[IsReverse] <> 1 THEN 1 ELSE 0 END
FROM            
    [dbo].[AgentOtherCharge] O (NOLOCK)
	JOIN [dbo].[OtherChargesMemo] OCM (NOLOCK) ON O.[IdOtherChargesMemo] = OCM.[IdOtherChargesMemo]
    JOIN [dbo].[AgentBalance] B (NOLOCK) ON O.[IdAgent] = B.[IdAgent] AND O.[IdAgentBalance] = B.[IdAgentBalance]
WHERe
    O.[IdAgentOtherCharge]=@IdAgentOtherCharge

--select @IdAgent,@Amount,@Notes,@DebitOrCredit,@idotherchargesmemo

Exec st_SaveOtherCharge 
        @IdLenguage,
        @IdAgent,
        @Amount,
        @DebitOrCredit, -- IS DEBIT
        @DateOfMovement,
        @Notes,
        @IdAgentOtherCharge,
        @EnterByIdUser,
        @HasError Output,
        @Message Output,
        @idotherchargesmemo, --2	Oklahoma State Fee Return
        @OtherChargesMemoNote,
		1,
		@IsReverseOfReverse
if @HasError=0
begin
    insert into [ReverseAgentOtherCharge]
    values
    (@IdAgentOtherCharge,@DateOfMovement,@EnterByIdUser)
end

End Try                                  
Begin Catch  
                                 
 Set @HasError=1                         
 --Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,17)                                   
 SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE17')
 Declare @ErrorMessage nvarchar(max)                                   
 set @ErrorMessage = 'Agent: ' +ISNULL (CAST(@IdAgent as varchar) ,'Is null')+' Amount: ' + ISNULL(CAST( @Amount as varchar),'Is null') + 'Is debit: ' + ISNULL(Cast(@DebitOrCredit as varchar), 'Is null ') + +'Notes: '+ ISNULL(@Notes,'is null ') + 'User: '+ ISNULL(CAST(@EnterByIdUser as varchar) ,'Is null' )  + ERROR_MESSAGE()                                  
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SaveOtherChargeReverse',Getdate(),@ErrorMessage)                                  
End Catch