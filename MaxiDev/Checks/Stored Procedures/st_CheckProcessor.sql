CREATE procedure [Checks].[st_CheckProcessor]      
as     
/********************************************************************
<Author>Not Known</Author>
<app>MaxiJobs</app>
<Description></Description>

<ChangeLog>
<log Date="04/12/2018" Author="jmolina">Add with(nolock)</log>
<log Date="17/12/2018" Author="jmolina">Add ; in Insert/Update </log>
</ChangeLog>
********************************************************************/ 
Set nocount on    
BEGIN TRY 
	------------------------------------- validation, not running ------------------    
	Declare @TimesToReportFail int    
	Declare @FailCounter Int    
	Declare @IsRunning bit    
	Declare @Error nvarchar(max)    
    
	Set @Error='Error en st_CheckProcessor'+convert(varchar(30),getdate())    
      
	Select @TimesToReportFail=TimesToReportFail,    
	@FailCounter=FailCounter,    
	@IsRunning=IsRunning    
	From CheckProcessorInFail WITH(NOLOCK) Where Id=1    
      
	If  @IsRunning=1     
	Begin    
 
	 Update CheckProcessorInFail Set FailCounter=FailCounter+1 Where Id=1;

	 If @TimesToReportFail<=@FailCounter+1    
	  Begin    
	   EXEC st_SendMail 'Ciclado Check Transfer Processor',@Error    
	  End    
	End    
	Else    
	  Update  ProcessorInFail set FailCounter=0, IsRunning =1 Where Id=1;
      
	------------------------temp table -------------------------------------------      
      
	Create Table #Check
	(                  
		IdCheck int,
		IdStatus int
	)  
	
	    

	------ Fill the main table for the loop -----------------------------------------------------      
	Insert into #Check      
	Select IdCheck,IdStatus from [dbo].[Checks] WITH(NOLOCK)
	Where IdStatus in (41)
	Order by DateOfMovement asc;
	


	Declare @IdCheck int      
	Declare @IdStatus int      
	Declare @Priority int      

	-------- Main loop ---------------------------------------------------------------------------      
	While exists (Select 1 from #Check)
	Begin
	  Select top 1 @IdCheck=IdCheck,@IdStatus=IdStatus from #Check
	  Exec checks.[st_CheckTransferProcessorDetail] @IdCheck , @IdStatus;
	  Delete #Check where IdCheck=@IdCheck;
	End


	------------ Aviso ha terminado el store -------------------------------------------------------------------      
	 Update  CheckProcessorInFail set FailCounter=0, IsRunning =0 Where Id=1;

END TRY
BEGIN CATCH
	DECLARE @MessageError varchar(max)
	SET @MessageError = ERROR_MESSAGE();
	INSERT INTO dbo.ErrorLogForStoreProcedure(StoreProcedure, ErrorDate, ErrorMessage) VALUES('st_CheckProcessor', GETDATE(), @MessageError);
END CATCH
