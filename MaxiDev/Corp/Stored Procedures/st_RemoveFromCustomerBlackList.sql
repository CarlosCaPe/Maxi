CREATE PROCEDURE [Corp].[st_RemoveFromCustomerBlackList]
(
    @IdCustomerBlackList int,
    @IsSpanishLanguage int,
    @EnterByIdUser int,
    @HasError bit out,          
    @Message varchar(max) out
)
as

begin try

    update [CustomerBlackList] set idgenericstatus=2,enterbyiduser=@EnterByIdUser,dateoflastchange=getdate() where IdCustomerBlackList=@IdCustomerBlackList

    Set @HasError=0          
	Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,55)  
	
End Try          
Begin Catch          
 Set @HasError=1          
 Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,54)          
 Declare @ErrorMessage nvarchar(max)           
 Select @ErrorMessage=ERROR_MESSAGE()          
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_RemoveFromCustomerBlackList]',Getdate(),@ErrorMessage)          
End Catch
