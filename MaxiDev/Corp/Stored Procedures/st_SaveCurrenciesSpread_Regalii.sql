
-- =============================================
-- ChangeLog--
-- Author:	omurillo
-- Modify date: 2020-10-28
-- Description:	Se cambio el nombre de la base de datos donde se guardan los logs de historial [MAXI_LOG] por [MAXILOG] 
-- =============================================
CREATE procedure [Corp].[st_SaveCurrenciesSpread_Regalii]
(
    @IdCurrenciesSpread int,
	@IdCurrenciesSpreadOut int out,
    @IdCurrency int,
    @IdAgent int = null,
    @Spread money,
    @IdGenericStatus int ,
    @EnterByIdUser int ,
    @IdLenguage int,
    @HasError Bit out,
    @MessageError nvarchar (max) out
)
as
Begin Try  
Declare @dataxml xml
Declare @TaskLog nvarchar(max)

if @IdCurrenciesSpread=0
begin
    if exists (select top 1 1 from Regalii.[CurrenciesSpread] with(nolock) where IdCurrency=@IdCurrency and isnull(Idagent,0)=isnull(@IdAgent,0))
    begin
        Set @MessageError=1          
        Select @MessageError =dbo.GetMessageFromMultiLenguajeResorces(@IdLenguage,'SpreadSaveError')  
        return
    end

    INSERT INTO [Regalii].[CurrenciesSpread]
           ([IdCurrency]
           ,[IdAgent]
           ,[Spread]
           ,[IdGenericStatus]
           ,[EnterByIdUser]
           ,[DateOfLastChange])
     VALUES
           (@IdCurrency
           ,@IdAgent
           ,@Spread
           ,@IdGenericStatus
           ,@EnterByIdUser
           ,getdate())

    set @IdCurrenciesSpreadOut = SCOPE_IDENTITY()

    set @TaskLog = 'INSERT'
end
else
begin
    UPDATE [Regalii].[CurrenciesSpread]
    SET [IdCurrency] = @IdCurrency
         ,[IdAgent] = @IdAgent
        ,[Spread] = @Spread
        ,[IdGenericStatus] = @IdGenericStatus
        ,[EnterByIdUser] = @EnterByIdUser
        ,[DateOfLastChange] = Getdate()
    WHERE IdCurrenciesSpread=@IdCurrenciesSpread

    set @TaskLog = 'UPDATE'
end

    set @dataxml = (select IdCurrenciesSpread, IdCurrency, IdAgent, Spread, IdGenericStatus, EnterByIdUser, DateOfLastChange from Regalii.[CurrenciesSpread] with(nolock) where IdCurrenciesSpread=@IdCurrenciesSpread FOR XML RAW)
    
    insert into [MAXILOG].[dbo].[GenericTableLog]
    (ObjectName,IdGeneric,Operation,XMLValues,DateOfLastChange,EnterByIdUser)
    values
    ('Regalii.CurrenciesSpread',@IdCurrenciesSpread,@TaskLog,@dataxml,GETDATE(),@EnterByIdUser)

	Set @HasError=0          
	Select @MessageError =dbo.GetMessageFromMultiLenguajeResorces(@IdLenguage,'SpreadSaveOk')  
	
End Try          
Begin Catch          
 Set @MessageError=1          
 Select @MessageError =dbo.GetMessageFromMultiLenguajeResorces(@IdLenguage,'SpreadSaveError')  
 Declare @ErrorMessage nvarchar(max)           
 Select @ErrorMessage=ERROR_MESSAGE()          
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_SaveCurrenciesSpread_Regalii',Getdate(),@ErrorMessage)          
End Catch