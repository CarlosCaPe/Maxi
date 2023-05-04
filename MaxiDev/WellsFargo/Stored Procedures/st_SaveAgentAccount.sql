--drop procedure [WellsFargo].st_SaveUserAccount

create procedure [WellsFargo].st_SaveAgentAccount
(
    @IdAgentAccount int,
    @IdAgent int,
    @Alias nvarchar(max),
    @FirstName nvarchar(max),
    @LastName nvarchar(max),
    @ZipCode nvarchar(max),
    @Street nvarchar(max),
    @City nvarchar(max),
    @State nvarchar(max),
    @Country nvarchar(max),
    @PhoneNUmber nvarchar(max),
    @Email nvarchar(max),
    @AccountNumber nvarchar(max),
    @RoutingNumber nvarchar(max),
    @AccountType  nvarchar(max),
    @BankName nvarchar(max),
    @EnterByIDUser int,
    @IdLenguage int,
    @IdAgentAccountOut int out,
    @HasError bit out,
    @MessageError nvarchar(max) out
)
as
begin try

--declaracion de variables
DECLARE @AccountNumberData VARBINARY(MAX)
DECLARE @RoutingNumberData VARBINARY(MAX)

--inicializacion de variables
OPEN SYMMETRIC KEY [MAXI_SECRETDATA_KEY] DECRYPTION BY CERTIFICATE [MAXI_CERTIFICATE];
				
				DECLARE @KeyGuid		AS UNIQUEIDENTIFIER;
				SET		@KeyGuid = key_guid( 'MAXI_SECRETDATA_KEY');
                set @AccountNumberData=DBO.[fnEncryptData](@KeyGuid,(CONVERT(varbinary(max), convert(varchar(max),@AccountNumber)))  )
                set @RoutingNumberData=DBO.[fnEncryptData](@KeyGuid,(CONVERT(varbinary(max), convert(varchar(max),@RoutingNumber)))  )

CLOSE SYMMETRIC KEY MAXI_SECRETDATA_KEY;

if (@IdAgentAccount=0)
begin
INSERT INTO [WellsFargo].[AgentAccount]
           ([IdAgent]
           ,[Alias]
           ,[FirstName]
           ,[LastName]
           ,[ZipCode]
           ,[Street]
           ,[City]
           ,[State]
           ,[Country]
           ,[PhoneNUmber]
           ,[Email]
           ,[AccountNumberData]
           ,[RoutingNumberData]
           ,[AccountType]
           ,[EnterByIDUser]
           ,[DateOfCreation]
           ,[DateOfLastChange]
           ,[IdGenericStatus]
           ,BankName
           )
     VALUES
           (@IdAgent
           ,@Alias
           ,@FirstName
           ,@LastName
           ,@ZipCode
           ,@Street
           ,@City
           ,@State
           ,@Country
           ,@PhoneNUmber
           ,@Email
           ,@AccountNumberData
           ,@RoutingNumberData
           ,@AccountType
           ,@EnterByIDUser
           ,getdate()
           ,getdate()
           ,1
           ,isnull(@BankName,'')
           )

        set @IdAgentAccountOut = SCOPE_IDENTITY()
end
else
begin
    UPDATE [WellsFargo].[AgentAccount]
   SET [IdAgent] = @IdAgent
      ,[Alias] = @Alias
      ,[FirstName] = @FirstName
      ,[LastName] = @LastName
      ,[ZipCode] = @ZipCode
      ,[Street] = @Street
      ,[City] = @City
      ,[State] = @State
      ,[Country] = @Country
      ,[PhoneNUmber] = @PhoneNUmber
      ,[Email] = @Email
      ,[AccountNumberData] = @AccountNumberData
      ,[RoutingNumberData] = @RoutingNumberData 
      ,[AccountType] = @AccountType
      ,[EnterByIDUser] = @EnterByIDUser      
      ,[DateOfLastChange] = getdate()  
      ,[BankName] =isnull(@BankName,'')
 WHERE IdAgentAccount=@IdAgentAccount

 set @IdAgentAccountOut=@IdAgentAccount
end

set @HasError = 0
set @MessageError=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SAVEWFACCOUNT')

End Try
Begin Catch
	Set @HasError=1	
    set @MessageError=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'ERRORSAVEWFACCOUNT')
	Declare @ErrorMessage nvarchar(max)
	Select @ErrorMessage=ERROR_MESSAGE()
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('WellsFargo.st_SaveAgentAccount',Getdate(),@ErrorMessage)
End Catch