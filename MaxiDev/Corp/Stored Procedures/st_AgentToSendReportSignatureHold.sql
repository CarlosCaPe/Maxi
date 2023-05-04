CREATE PROCEDURE [Corp].[st_AgentToSendReportSignatureHold]
(
	@IdAgent int = null
)
AS  

Set nocount on;

/*Quitar en produccion*/
/*--------------------*/
Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)
	Values('Corp.st_AgentToSendReportSignatureHold',Getdate(),'Parameters:IdAgent=' + CONVERT(VARCHAR(25),ISNULL(@IdAgent,'')));
/*--------------------*/

Begin try

	Select 
		Distinct 
			C.IdAgent
			,C.AgentCode
			,C.AgentName
			,C.AgentFax
			,C.ExcludeReportSignatureHold
	from Transfer AS A WITH(NOLOCK)
		Join TransferHolds AS B WITH(NOLOCK) on (A.IdTransfer=B.IdTransfer and B.IdStatus=3 and B.IsReleased is null)  
		Join Agent AS C WITH(NOLOCK) on (A.IdAgent=C.IdAgent)
	Where A.IdStatus = 41 
		and DATEDIFF(MINUTE,B.DateOfValidation,GETDATE()) >=dbo.GetGlobalAttributeByName('Minutes In Signature Hold')
		and (C.IdAgent = ISNULL(@IdAgent,C.IdAgent));

End try
Begin Catch    
	DECLARE @ErrorMessage varchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_AgentToSendReportSignatureHold',Getdate(),@ErrorMessage);
End catch
