CREATE PROCEDURE [Corp].[st_getComplianceProducts]
(
    @IdStatus int
	,@IdTransfer int = NULL
)
as
Begin Try

		select 
			IdComplianceProduct
			,nameen+' / '+name
			,nameen
			,name 
		from ComplianceProducts WITH(NOLOCK)
			where idstatus = @IdStatus
	Union All
		select 
			IdComplianceProduct
			,nameen+' / '+name
			,nameen
			,name 
		from ComplianceProducts WITH(NOLOCK)
			where IdStatus =
				(
					select H.IdStatus
						from transfer T with(nolock)
							join TransferHolds H with(nolock) on T.IdTransfer=H.IdTransfer and H.IdStatus=3 and H.IsReleased is null
						where T.IdStatus = 41 
							and T.IdTransfer = ISNULL(@IdTransfer,0)
				)
	order by IdComplianceProduct;

End try
Begin catch
    Declare @ErrorMessage nvarchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_getComplianceProducts',Getdate(),@ErrorMessage);
End catch
