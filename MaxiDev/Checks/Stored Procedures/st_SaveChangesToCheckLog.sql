
CREATE  Procedure [Checks].[st_SaveChangesToCheckLog]          
(          
    @Idcheck int,          
    @IdStatus int,          
    @Note nvarchar(max),        
    @IdUser int    
)          
As      
/********************************************************************
<Author>Not Known</Author>
<app>MaxiJobs</app>
<Description></Description>

<ChangeLog>
<log Date="17/12/2018" Author="jmolina">Add ; in Insert/Update </log>
</ChangeLog>
********************************************************************/ 
Set nocount on          
Begin Try          
	Declare @IdValue int

	If @IdUser=0    
	Begin    
	 Select  @IdUser=dbo.GetGlobalAttributeByName('SystemUserID')    
	end        

	declare @DateNow Datetime
	Set @DateNow = GETDATE()

	if(@IdStatus = 41 or @IdStatus =  31)
	begin
		Set @DateNow = @DateNow  -- + .001
	end

	Insert into [CheckDetails] (IdStatus,IdCheck,DateOfMovement,note,EnterByIdUser) values (@IdStatus,@Idcheck,@DateNow,@Note,@IdUser);

	Select @IdValue=SCOPE_IDENTITY ()                

End Try                  
Begin Catch                  
	 Declare @ErrorMessage nvarchar(max)                   
	 Select @ErrorMessage=ERROR_MESSAGE()                  
	 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SaveChangesToCheckLog',Getdate(),@ErrorMessage)                  
End Catch  
