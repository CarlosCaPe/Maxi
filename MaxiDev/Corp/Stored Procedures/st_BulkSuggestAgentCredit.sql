CREATE PROCEDURE [Corp].[st_BulkSuggestAgentCredit]
(
    @AgentsData XML,
    @IsApprove bit,    
    @IdUser INT,
    @IsSpanishLanguage INT,    
    @HasError BIT OUT,
    @MessageOut varchar(max) OUT
)
AS
/********************************************************************
<Author></Author>
<app></app>
<Description>Actualiza los registros de las agencias canidatas a reduccion de limite de credito</Description>

<ChangeLog>
<log Date="19/07/2018" Author="snevarez"> CO_003_SuggestCreditLimit </log>
</ChangeLog>
*********************************************************************/
DECLARE @DocHandle INT 
DECLARE @IdAgentSuggest int
DECLARE @IdAgent int 
DECLARE @CreditLimitSuggested money

--Inicializar Variables
Set @HasError=0;
Select @MessageOut = dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,79) ;  

BEGIN TRY

    EXEC sp_xml_preparedocument @DocHandle OUTPUT,@AgentsData;

    Create Table #Credit
    (    
	   IdAgentSuggest INT
    );

    --Guardar informacion de Creditos en tabla temporal
    INSERT INTO #Credit
    SELECT value From OPENXML (@DocHandle, '/root/value',2) 
	   WITH (      
		  value INT 'text()'
	   );

    delete from #Credit where isnull(IdAgentSuggest,0) = 0;

    While exists (Select top 1 1 from #Credit)
    BEGIN
	   Select top 1 @IdAgentSuggest=IdAgentSuggest from #Credit;
    
	   update [AgentCreditSuggest] 
		  set EnterByIdUser=@IdUser
			 , DateOfLastChange=getdate()
			 , IsApproved=@IsApprove
			 , @CreditLimitSuggested=round(Suggested,2)
			 , @IdAgent=IdAgent  
	   where IdAgentCreditSuggest=@IdAgentSuggest
    
	   if (@IsApprove=1)
	   begin
		  exec [Corp].[st_SaveAgentMirror] @IdAgent 
		  update agent set creditamount=@CreditLimitSuggested,dateoflastchange=getdate(), enterbyiduser=@IdUser  where idagent=@IdAgent;

		  Declare @HasErrorLH bit;

		 EXEC [Corp].[st_SaveAgentCreditLimitHistory]
			   @IdAgent = @IdAgent,   
			   @CreditLimitSuggested = @CreditLimitSuggested,
			   @EnterbyIdUser = @IdUser,
			   @Note = 'Credit reduction suggestion',
			   @HasError = @HasErrorLH OUTPUT;
	   end

	   Delete #Credit where IdAgentSuggest = @IdAgentSuggest;
    END

END TRY
BEGIN CATCH
	Set @HasError=1;
	Select @MessageOut = dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,80);
	Declare @ErrorMessage nvarchar(max);
	Select @ErrorMessage=ERROR_MESSAGE();
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_BulkSuggestAgentCredit]',Getdate(),@ErrorMessage);
END CATCH
