CREATE procedure [WellsFargo].[st_CreateTransferWFEcheck]
(
    @IdAgent int,
    @EnterByIdUser int,
    @Token nvarchar(max),
    @FirstName nvarchar(1000),
    @LastName nvarchar(1000),
    @ZipCode nvarchar(5),
    @Street nvarchar(max),
    @City nvarchar(max),
    @State nvarchar(max),
    @Country nvarchar(max),
    @PhoneNumber nvarchar(max),
    @Email nvarchar(max),
    @AccountNumber nvarchar(max),
    @RoutingNumber nvarchar(max),    
    @AccountType nvarchar(1),
    @Amount money,
    @MinimunAmount money,
    @Request nvarchar(max),
    @RequestDate datetime,
    @Response nvarchar(max),
    @ResponseDate datetime,
    @ReasonCode nvarchar(max),
    @ReconcilationID nvarchar(max),
    @TransID nvarchar(max),
    @Folio nvarchar(max),
    @IdAgentAccount int = null,
    @BankName nvarchar(max),    
    @Alias nvarchar(max),
    @Reference nvarchar(max),
    @ApplyDate datetime,
    @IdLenguage int,
    @IdTransferWFEcheck int out,
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


INSERT INTO [WellsFargo].[TransferWFEcheck]
           ([IdAgent]
           ,[Token]
           ,[FirstName]
           ,[LastName]
           ,[ZipCode]
           ,[Street]
           ,[City]
           ,[State]
           ,[Country]
           ,[PhoneNUmber]
           ,[Email]
           --,[DriverLicenceNumber]
           --,[DriverLicenceState]
           --,[AccountNumber]
           --,[RoutingNumber]
           ,[AccountType]
           ,[Amount]
           ,[MinimunAmount]
           ,[Request]
           ,[RequestDate]
           ,[Response]
           ,[ResponseDate]
           ,[ReasonCode]
           ,[ReconcilationID]
           ,[TransID]
           ,[Folio]
           ,[EnterByIDUser]
           ,[DateOfCreation]
           ,AccountNumberData
           ,RoutingNumberData
           ,IdAgentAccount
           ,BankName
           ,Alias
           ,Reference
           ,ApplyDate
           )
     VALUES
           (@IdAgent
           ,@Token
           ,@FirstName
           ,@LastName
           ,@ZipCode
           ,@Street
           ,@City
           ,@State
           ,@Country
           ,@PhoneNUmber
           ,isnull(@Email,'')
           --,@DriverLicenceNumber
           --,@DriverLicenceState
           --,@AccountNumber
           --,@RoutingNumber
           ,@AccountType
           ,@Amount
           ,@MinimunAmount
           ,@Request
           ,@RequestDate
           ,@Response
           ,@ResponseDate
           ,@ReasonCode
           ,@ReconcilationID
           ,@TransID
           ,@Folio
           ,@EnterByIdUser
           ,getdate()
           ,@AccountNumberData
           ,@RoutingNumberData
           ,@IdAgentAccount
           ,isnull(@BankName,'')
           ,isnull(@Alias,'')
           ,isnull(@Reference,'')
           ,@ApplyDate
           )

set @IdTransferWFEcheck = SCOPE_IDENTITY()

set @HasError = 0
set @MessageError=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE06')

End Try
Begin Catch
	Set @HasError=1	
    set @MessageError=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE07')
	Declare @ErrorMessage nvarchar(max)
	Select @ErrorMessage=ERROR_MESSAGE()
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('WellsFargo.st_CreateTransferWFEcheck',Getdate(),@ErrorMessage)
End Catch