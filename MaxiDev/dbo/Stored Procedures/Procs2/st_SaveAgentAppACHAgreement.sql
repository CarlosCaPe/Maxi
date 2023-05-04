create procedure st_SaveAgentAppACHAgreement
(
    @IdAgentApplication [int] ,		
    @BankName [nvarchar](max),
    @Addreess [nvarchar](max) ,	
	@City [nvarchar](max) ,
	@State [nvarchar](max) ,
	@ZipCode [nvarchar](max) ,	        
	@EnterByIdUser [int],
    @HasError bit out 
)
as

begin try

set @HasError=0

INSERT INTO [dbo].[AgentAppACHAgreement]
           ([IdAgentApplication]
           ,[BankName]
           ,[Addreess]
           ,[City]
           ,[State]
           ,[ZipCode]           
           ,[EnterByIdUser]
           ,[DateOfLastChange])
     VALUES
           (@IdAgentApplication
           ,@BankName
           ,@Addreess
           ,@City
           ,@State
           ,@ZipCode           
           ,@EnterByIdUser
           ,getdate())

end try
begin catch
    set @HasError=1    
    Declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SaveAgentAppACHAgreement',Getdate(),@ErrorMessage)   
end catch