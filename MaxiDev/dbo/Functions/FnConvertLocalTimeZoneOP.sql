
CREATE function [dbo].[FnConvertLocalTimeZoneOP] (@IdTransfer int,@receiptType int)
 
 Returns @result table (DateOfTransferLocal datetime, PrintedDate datetime,TimeZone nvarchar(3))

AS

BEGIN  
 --- Conversion Hora Local  BP-TU
	

	IF (@receiptType=1)

-- TU
		BEGIN
		 
		       Insert into @result

				    select 
					       case when t.[DateOfCreationUTC] is not null and z.TimeZone='PST' THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset, t.[DateOfCreationUTC]), '-07:00'))
								when t.[DateOfCreationUTC] is not null and z.TimeZone='MST'AND z.StateCode='AZ' and z.DaylightSavingTime=0 THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset, t.[DateOfCreationUTC]), '-07:00'))
								when t.[DateOfCreationUTC] is not null and z.TimeZone='MST' THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset, t.[DateOfCreationUTC]), '-06:00'))
								when t.[DateOfCreationUTC] is not null and z.TimeZone='CST' THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset, t.[DateOfCreationUTC]), '-05:00'))
								when t.[DateOfCreationUTC] is not null and z.TimeZone='EST' THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset, t.[DateOfCreationUTC]), '-04:00'))
								when t.[DateOfCreationUTC] is null THEN t.DateOfCreation --AT TIME ZONE 'Central Standard Time'
							end DateOfTransferLocal,
					        case when z.TimeZone='PST' THEN   CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset,GETUTCDATE()), '-07:00'))
						        when z.TimeZone='MST' AND z.StateCode='AZ' and z.DaylightSavingTime=0 THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset, t.[DateOfCreationUTC]), '-07:00'))
						        when z.TimeZone='MST' THEN   CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset,GETUTCDATE()), '-06:00'))
						        when z.TimeZone='CST' THEN   CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset,GETUTCDATE()), '-05:00'))
						        when z.TimeZone='EST' THEN   CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset,GETUTCDATE()), '-04:00'))
						    end PrintedDate,
			         		case when t.[DateOfCreationUTC] is null THEN 'CST' ELSE Z.TimeZone 
				            end TimeZone
					from [Operation].[ProductTransfer] t with(nolock) 
					join Agent a with(nolock) on t.IdAgent=a.IdAgent
					join ZipCodeTimeZone z with(nolock) on a.AgentZipcode=z.Number
					where t.IdProductTransfer=@IdTransfer
			END

	ElSE IF (@receiptType=2)

-- BP Esquema BillPayment
		BEGIN 
				
				Insert into @result
				 select 
					       case when t.[DateOfCreationUTC] is not null and z.TimeZone='PST' THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset, t.[DateOfCreationUTC]), '-07:00'))
								when t.[DateOfCreationUTC] is not null and z.TimeZone='MST'AND z.StateCode='AZ' and z.DaylightSavingTime=0 THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset, t.[DateOfCreationUTC]), '-07:00'))
								when t.[DateOfCreationUTC] is not null and z.TimeZone='MST' THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset, t.[DateOfCreationUTC]), '-06:00'))
								when t.[DateOfCreationUTC] is not null and z.TimeZone='CST' THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset, t.[DateOfCreationUTC]), '-05:00'))
								when t.[DateOfCreationUTC] is not null and z.TimeZone='EST' THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset, t.[DateOfCreationUTC]), '-04:00'))
								when t.[DateOfCreationUTC] is null THEN t.DateOfCreation --AT TIME ZONE 'Central Standard Time'
							end DateOfTransferLocal,
					        case when z.TimeZone='PST' THEN   CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset,GETUTCDATE()), '-07:00'))
						        when z.TimeZone='MST' AND z.StateCode='AZ' and z.DaylightSavingTime=0 THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset, t.[DateOfCreationUTC]), '-07:00'))
						        when z.TimeZone='MST' THEN   CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset,GETUTCDATE()), '-06:00'))
						        when z.TimeZone='CST' THEN   CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset,GETUTCDATE()), '-05:00'))
						        when z.TimeZone='EST' THEN   CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset,GETUTCDATE()), '-04:00'))
						    end PrintedDate,
			         		case when t.[DateOfCreationUTC] is null THEN 'CST' ELSE Z.TimeZone 
				            end TimeZone
					from [BillPayment].[TransferR] t with(nolock) 
					join Agent a with(nolock) on t.IdAgent=a.IdAgent
					join ZipCodeTimeZone z with(nolock) on a.AgentZipcode=z.Number
					where t.IdProductTransfer=@IdTransfer
		END
	
				
	ElSE IF (@receiptType=3)

-- BP Esquema Regalli

		BEGIN 
					  
				Insert into @result
                 
					select 
					       case when t.[DateOfCreationUTC] is not null and z.TimeZone='PST' THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset, t.[DateOfCreationUTC]), '-07:00'))
								when t.[DateOfCreationUTC] is not null and z.TimeZone='MST'AND z.StateCode='AZ' and z.DaylightSavingTime=0 THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset, t.[DateOfCreationUTC]), '-07:00'))
								when t.[DateOfCreationUTC] is not null and z.TimeZone='MST' THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset, t.[DateOfCreationUTC]), '-06:00'))
								when t.[DateOfCreationUTC] is not null and z.TimeZone='CST' THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset, t.[DateOfCreationUTC]), '-05:00'))
								when t.[DateOfCreationUTC] is not null and z.TimeZone='EST' THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset, t.[DateOfCreationUTC]), '-04:00'))
								when t.[DateOfCreationUTC] is null THEN t.DateOfCreation --AT TIME ZONE 'Central Standard Time'
							end DateOfTransferLocal,
					        case when z.TimeZone='PST' THEN   CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset,GETUTCDATE()), '-07:00'))
						        when z.TimeZone='MST' AND z.StateCode='AZ' and z.DaylightSavingTime=0 THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset, t.[DateOfCreationUTC]), '-07:00'))
						        when z.TimeZone='MST' THEN   CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset,GETUTCDATE()), '-06:00'))
						        when z.TimeZone='CST' THEN   CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset,GETUTCDATE()), '-05:00'))
						        when z.TimeZone='EST' THEN   CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset,GETUTCDATE()), '-04:00'))
						    end PrintedDate,
			         		case when t.[DateOfCreationUTC] is null THEN 'CST' ELSE Z.TimeZone 
				            end TimeZone
					from [Regalii].[TransferR] t with(nolock) 
					join Agent a with(nolock) on t.IdAgent=a.IdAgent
					join ZipCodeTimeZone z with(nolock) on a.AgentZipcode=z.Number
					where t.IdProductTransfer=@IdTransfer
		END

	
           
		   return;

		
 END

