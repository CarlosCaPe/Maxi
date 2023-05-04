create procedure st_SaveCustomerBlackListRule
(
    @IdCustomerBlackListRule int,
    @Alias nvarchar(max),
    @RuleNameInSpanish nvarchar(max),
    @RuleNameInEnglish nvarchar(max),    
    @IdCBLAction int,
    @MessageInSpanish nvarchar(max),
    @MessageInEnglish nvarchar(max),
    @IdGenericStatus int,
    @EnterByIdUser int,
    @IsSpanishLanguage bit,          
    @IdCustomerBlackListRuleOUT int out,
    @HasError bit out,          
    @Message varchar(max) out
)
as
begin try
if @IdCustomerBlackListRule=0
begin
    
   INSERT INTO [dbo].[CustomerBlackListRule]
           (
            [Alias]
           ,[RuleNameInSpanish]
           ,[RuleNameInEnglish]           
           ,[IdCBLAction]
           ,[MessageInSpanish]
           ,[MessageInEnglish]
           ,[IdGenericStatus]
           ,[DateOfLastChange]
           ,[EnterByIdUser]           
           )
   VALUES
           (
            @Alias,
            @RuleNameInSpanish,
            @RuleNameInEnglish,            
            @IdCBLAction,
            @MessageInSpanish,
            @MessageInEnglish,
            @IdGenericStatus,
            getdate(),
            @EnterByIdUser            
            )

    set @IdCustomerBlackListRuleOUT=SCOPE_IDENTITY()

end
else
begin
   UPDATE [dbo].[CustomerBlackListRule]
   SET 
       [Alias] = @Alias
      ,[RuleNameInSpanish] = @RuleNameInSpanish
      ,[RuleNameInEnglish] = @RuleNameInEnglish
      ,[IdCBLAction] = @IdCBLAction
      ,[MessageInSpanish] = @MessageInSpanish
      ,[MessageInEnglish] = @MessageInEnglish
      ,[IdGenericStatus] = @IdGenericStatus
      ,[DateOfLastChange] = getdate()
      ,[EnterByIdUser] = @EnterByIdUser
    WHERE 
        IdCustomerBlackListRule=@IdCustomerBlackListRule

   set @IdCustomerBlackListRuleOut=@IdCustomerBlackListRule
end

	Set @HasError=0          
	Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,55)  
	
End Try          
Begin Catch          
 Set @HasError=1          
 Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,54)          
 Declare @ErrorMessage nvarchar(max)           
 Select @ErrorMessage=ERROR_MESSAGE()          
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SaveCustomerBlackListRule',Getdate(),@ErrorMessage)          
End Catch  
