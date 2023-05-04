
CREATE function [dbo].[FnConvertLocalTimeZoneCancel] (@IdTransfer int,@receiptType int)
 
 Returns @result table (DateOfTransferLocal datetime, PrintedDate datetime,TimeZone nvarchar(3))

AS

BEGIN  
 --- Conversion Hora Local Cancelaciones Transfer, TransferClosed
	
	IF (@receiptType=2)

		BEGIN 
				IF EXISTS (SELECT 1 FROM Transfer with(nolock) WHERE IdTransfer=@IdTransfer)

					begin	
						Insert into @result
				
							 select case when t.DateStatusChange is not null and z.TimeZone='PST' THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset,DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), t.DateStatusChange)), '-07:00'))
										 when t.DateStatusChange is not null and z.TimeZone='MST'AND z.StateCode='AZ' and z.DaylightSavingTime=0 THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset,DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), t.DateStatusChange)), '-07:00'))
										 when t.DateStatusChange is not null and z.TimeZone='MST' THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset,DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), t.DateStatusChange)), '-06:00'))
										 when t.DateStatusChange is not null and z.TimeZone='CST' THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset,DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), t.DateStatusChange)), '-05:00'))
										 when t.DateStatusChange is not null and z.TimeZone='EST' THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset,DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), t.DateStatusChange)), '-04:00'))
										 when t.DateStatusChange is null THEN t.DateStatusChange --AT TIME ZONE 'Central Standard Time'
										 end DateOfTransferLocal,
									case when z.TimeZone='PST' THEN   CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset,GETUTCDATE()), '-07:00'))
										 when z.TimeZone='MST' AND z.StateCode='AZ' and z.DaylightSavingTime=0 THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset,DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), t.DateStatusChange)), '-07:00'))
										 when z.TimeZone='MST' THEN   CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset,GETUTCDATE()), '-06:00'))
										 when z.TimeZone='CST' THEN   CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset,GETUTCDATE()), '-05:00'))
										 when z.TimeZone='EST' THEN   CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset,GETUTCDATE()), '-04:00'))
										 end PrintedDate,			
									case when DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), t.DateStatusChange) is null THEN 'CST' ELSE Z.TimeZone 
										 end TimeZone
								from Transfer t with(nolock) 
								join Agent a with(nolock) on t.IdAgent=a.IdAgent
								join ZipCodeTimeZone z with(nolock) on a.AgentZipcode=z.Number
									where t.IdTransfer=@IdTransfer
					 end 
	
				ELSE 
					begin
					   Insert into @result
                 
							select case when t.DateStatusChange is not null and z.TimeZone='PST' THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset,DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), t.DateStatusChange)), '-07:00'))
										 when t.DateStatusChange is not null and z.TimeZone='MST'AND z.StateCode='AZ' and z.DaylightSavingTime=0 THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset,DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), t.DateStatusChange)), '-07:00'))
										 when t.DateStatusChange is not null and z.TimeZone='MST' THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset,DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), t.DateStatusChange)), '-06:00'))
										 when t.DateStatusChange is not null and z.TimeZone='CST' THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset,DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), t.DateStatusChange)), '-05:00'))
										 when t.DateStatusChange is not null and z.TimeZone='EST' THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset,DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), t.DateStatusChange)), '-04:00'))
										 when t.DateStatusChange is null THEN t.DateStatusChange --AT TIME ZONE 'Central Standard Time'
										 end DateOfTransferLocal,
									case when z.TimeZone='PST' THEN   CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset,GETUTCDATE()), '-07:00'))
										 when z.TimeZone='MST' AND z.StateCode='AZ' and z.DaylightSavingTime=0 THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset,DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), t.DateStatusChange)), '-07:00'))
										 when z.TimeZone='MST' THEN   CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset,GETUTCDATE()), '-06:00'))
										 when z.TimeZone='CST' THEN   CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset,GETUTCDATE()), '-05:00'))
										 when z.TimeZone='EST' THEN   CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset,GETUTCDATE()), '-04:00'))
										 end PrintedDate,			
									case when DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), t.DateStatusChange) is null THEN 'CST' ELSE Z.TimeZone 
										 end TimeZone
								from TransferClosed t with(nolock) 
								join Agent a with(nolock) on t.IdAgent=a.IdAgent
								join ZipCodeTimeZone z with(nolock) on a.AgentZipcode=z.Number
									where t.IdTransferClosed=@IdTransfer
					end

		END
           


		   return;

		
 END

