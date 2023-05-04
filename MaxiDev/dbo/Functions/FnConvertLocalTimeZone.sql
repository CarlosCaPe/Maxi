

CREATE function [dbo].[FnConvertLocalTimeZone] (@IdTransfer int,@receiptType bit)
 
 Returns @result table (DateOfTransferLocal datetime, PrintedDate datetime,TimeZone nvarchar(3))

AS

BEGIN  
 --- Conversion Hora Local  PreTransfer, Transfer, TransferClosed
	

	IF (@receiptType=1)

		Begin
		 
		       Insert into @result

					select case when t.DateOfPreTransferUTC is not null and z.TimeZone='PST' THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset, t.DateOfPreTransferUTC), '-07:00'))
						 when t.DateOfPreTransferUTC is not null and z.TimeZone='MST'AND z.StateCode='AZ' and z.DaylightSavingTime=0 THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset, t.DateOfPreTransferUTC), '-07:00'))
						 when t.DateOfPreTransferUTC is not null and z.TimeZone='MST' THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset, t.DateOfPreTransferUTC), '-06:00'))
						 when t.DateOfPreTransferUTC is not null and z.TimeZone='CST' THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset, t.DateOfPreTransferUTC), '-05:00'))
						 when t.DateOfPreTransferUTC is not null and z.TimeZone='EST' THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset, t.DateOfPreTransferUTC), '-04:00'))
						 when t.DateOfPreTransferUTC is null THEN t.DateOfPreTransferUTC --AT TIME ZONE 'Central Standard Time'
						 end DateOfTransferLocal,
					case when z.TimeZone='PST' THEN   CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset,GETUTCDATE()), '-07:00'))
						 when z.TimeZone='MST' AND z.StateCode='AZ' and z.DaylightSavingTime=0 THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset, t.DateOfPreTransferUTC), '-07:00'))
						 when z.TimeZone='MST' THEN   CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset,GETUTCDATE()), '-06:00'))
						 when z.TimeZone='CST' THEN   CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset,GETUTCDATE()), '-05:00'))
						 when z.TimeZone='EST' THEN   CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset,GETUTCDATE()), '-04:00'))
						 end PrintedDate,
			
					case when t.DateOfPreTransferUTC is null THEN 'CST' ELSE Z.TimeZone 
						 end TimeZone
				from PreTransfer t with(nolock) 
				join Agent a with(nolock) on t.IdAgent=a.IdAgent
				join ZipCodeTimeZone z with(nolock) on a.AgentZipcode=z.Number
					where t.IdPreTransfer=@IdTransfer
			end

	ElSE 
		begin 
				IF EXISTS (SELECT 1 FROM Transfer with(nolock) WHERE IdTransfer=@IdTransfer)
					begin	
						Insert into @result
				
							 select case when t.DateOfTransferUTC is not null and z.TimeZone='PST' THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset, t.DateOfTransferUTC), '-07:00'))
										 when t.DateOfTransferUTC is not null and z.TimeZone='MST'AND z.StateCode='AZ' and z.DaylightSavingTime=0 THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset, t.DateOfTransferUTC), '-07:00'))
										 when t.DateOfTransferUTC is not null and z.TimeZone='MST' THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset, t.DateOfTransferUTC), '-06:00'))
										 when t.DateOfTransferUTC is not null and z.TimeZone='CST' THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset, t.DateOfTransferUTC), '-05:00'))
										 when t.DateOfTransferUTC is not null and z.TimeZone='EST' THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset, t.DateOfTransferUTC), '-04:00'))
										 when t.DateOfTransferUTC is null THEN t.DateOfTransfer --AT TIME ZONE 'Central Standard Time'
										 end DateOfTransferLocal,
									case when z.TimeZone='PST' THEN   CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset,GETUTCDATE()), '-07:00'))
										 when z.TimeZone='MST' AND z.StateCode='AZ' and z.DaylightSavingTime=0 THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset, t.DateOfTransferUTC), '-07:00'))
										 when z.TimeZone='MST' THEN   CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset,GETUTCDATE()), '-06:00'))
										 when z.TimeZone='CST' THEN   CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset,GETUTCDATE()), '-05:00'))
										 when z.TimeZone='EST' THEN   CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset,GETUTCDATE()), '-04:00'))
										 end PrintedDate,			
									case when t.DateOfTransferUTC is null THEN 'CST' ELSE Z.TimeZone 
										 end TimeZone
								from Transfer t with(nolock) 
								join Agent a with(nolock) on t.IdAgent=a.IdAgent
								join ZipCodeTimeZone z with(nolock) on a.AgentZipcode=z.Number
									where t.IdTransfer=@IdTransfer
					 end
	
				ELSE 
					begin
					   Insert into @result
                 
							 select case when t.DateOfTransferUTC is not null and z.TimeZone='PST' THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset, t.DateOfTransferUTC), '-07:00'))
										 when t.DateOfTransferUTC is not null and z.TimeZone='MST' AND z.StateCode='AZ' and z.DaylightSavingTime=0 THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset, t.DateOfTransferUTC), '-07:00'))
										 when t.DateOfTransferUTC is not null and z.TimeZone='MST' THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset, t.DateOfTransferUTC), '-06:00'))
										 when t.DateOfTransferUTC is not null and z.TimeZone='CST' THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset, t.DateOfTransferUTC), '-05:00'))
										 when t.DateOfTransferUTC is not null and z.TimeZone='EST' THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset, t.DateOfTransferUTC), '-04:00'))
										 when t.DateOfTransferUTC is null THEN t.DateOfTransfer --AT TIME ZONE 'Central Standard Time'
										 end DateOfTransferLocal,
									case when z.TimeZone='PST' THEN   CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset,GETUTCDATE()), '-07:00'))
										 when z.TimeZone='MST' AND z.StateCode='AZ' and z.DaylightSavingTime=0 THEN CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset, t.DateOfTransferUTC), '-07:00'))
										 when z.TimeZone='MST' THEN   CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset,GETUTCDATE()), '-06:00'))
										 when z.TimeZone='CST' THEN   CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset,GETUTCDATE()), '-05:00'))
										 when z.TimeZone='EST' THEN   CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset,GETUTCDATE()), '-04:00'))
										 end PrintedDate,
			
									case when t.DateOfTransferUTC is null THEN 'CST' ELSE Z.TimeZone 
										 end TimeZone
								from TransferClosed t with(nolock) 
								join Agent a with(nolock) on t.IdAgent=a.IdAgent
								join ZipCodeTimeZone z with(nolock) on a.AgentZipcode=z.Number
									where t.IdTransferClosed=@IdTransfer
					end

		end
           
		   return;

		
 END

