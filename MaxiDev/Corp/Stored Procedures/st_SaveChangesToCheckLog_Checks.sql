CREATE PROCEDURE [Corp].[st_SaveChangesToCheckLog_Checks]          
(          
    @Idcheck int,          
    @IdStatus int,          
    @Note nvarchar(max),        
    @IdUser INT,
	@DateOfMovement DATETIME = NULL     
)          
As      
Set nocount on          
Begin Try          
Declare @IdValue int

If @IdUser=0    
Begin    
 Select  @IdUser=dbo.GetGlobalAttributeByName('SystemUserID')    
end        

declare @DateNow Datetime
SELECT @DateNow = CASE WHEN @DateOfMovement IS NULL THEN getdate() ELSE @DateOfMovement END

if(@IdStatus = 41 or @IdStatus =  31)
begin
	Set @DateNow = @DateNow + .001
end

Insert into [CheckDetails] (IdStatus,IdCheck,DateOfMovement,note,EnterByIdUser) values (@IdStatus,@Idcheck,@DateNow,@Note,@IdUser)          
Select @IdValue=SCOPE_IDENTITY ()                

End Try                  
Begin Catch                  
 Declare @ErrorMessage nvarchar(max)                   
 Select @ErrorMessage=ERROR_MESSAGE()                  
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SaveChangesToCheckLog',Getdate(),@ErrorMessage)                  
End Catch  

