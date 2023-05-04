CREATE PROCEDURE [Corp].[st_DeletePayerConfig]
@IdPayerConfig int,
@IsSpanishLanguage bit,  
@HasError bit out,  
@ResultMessage nvarchar(max) out  
as

if @IdPayerConfig=0 or not exists(select 1 from dbo.PayerConfig WITH (NOLOCK) where IdPayerConfig=@IdPayerConfig)
Begin
	set @HasError =1  
	set @ResultMessage = dbo.GetMessageFromLenguajeResorces(@IsSpanishLanguage,27)  
	return  
End
Begin Try
	
	delete dbo.LengthRule where  IdValidationRule in (select IdValidationRule from dbo.ValidationRules WITH (NOLOCK) where IdPayerConfig=@IdPayerConfig)
	delete dbo.RangeRule where  IdValidationRule in (select IdValidationRule from dbo.ValidationRules WITH (NOLOCK) where IdPayerConfig=@IdPayerConfig)
	delete dbo.SimpleComparisonRule where  IdValidationRule in (select IdValidationRule from dbo.ValidationRules WITH (NOLOCK) where IdPayerConfig=@IdPayerConfig)
	delete dbo.RegularExpressionRule where  IdValidationRule in (select IdValidationRule from dbo.ValidationRules WITH (NOLOCK) where IdPayerConfig=@IdPayerConfig)
	delete dbo.LengthRule where  IdValidationRule in (select IdValidationRule from dbo.ValidationRules WITH (NOLOCK) where IdPayerConfig=@IdPayerConfig)
	
	delete dbo.ValidationRules where IdPayerConfig=@IdPayerConfig
	delete dbo.AgentSchemaDetail where IdPayerConfig=@IdPayerConfig
	delete PayerConfig where IdPayerConfig=@IdPayerConfig

  set @HasError =0  
  set @ResultMessage = dbo.GetMessageFromLenguajeResorces(@IsSpanishLanguage,28)  
End try  
Begin Catch  
   Declare @ErrorMessage nvarchar(max)           
   Select @ErrorMessage=ERROR_MESSAGE()          
   Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[st_DeletePayerConfig]',Getdate(),@ErrorMessage)   
  set @HasError =1  
  set @ResultMessage = dbo.GetMessageFromLenguajeResorces(@IsSpanishLanguage,27)  
    
End catch

