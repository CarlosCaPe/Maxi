CREATE PROCEDURE [Corp].[st_GetTransferStatus]
	@IsAnActionStatus bit = null,
	@CanChangeToAgingHold bit = null,
	@SpecialChangeStatus bit = null
AS  

Set nocount on;
Begin try
	Select IdStatus, StatusName, PriorityVerification, InternalVerification, OldStatusName, IsAnActionStatus, 
	SpecialChangeStatus, RetainOperationStatus, RetainOperationStatusClabe, CanChangeToAgingHold, IdType
	from [Status] with(nolock) where IsAnActionStatus = ISNULL(@IsAnActionStatus,IsAnActionStatus) 
		and CanChangeToAgingHold = ISNULL(@CanChangeToAgingHold, CanChangeToAgingHold)
		and SpecialChangeStatus = ISNULL(@SpecialChangeStatus, SpecialChangeStatus)
	order by StatusName 

End try
Begin Catch    
	DECLARE @ErrorMessage varchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_GetTransferStatus',Getdate(),@ErrorMessage);
End catch


