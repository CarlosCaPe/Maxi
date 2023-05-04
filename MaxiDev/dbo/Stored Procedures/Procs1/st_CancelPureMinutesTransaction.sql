CREATE procedure [dbo].[st_CancelPureMinutesTransaction]
(
    @IdProductTransfer bigint,    
	@IdUser int ,	
    @PureMinutesUserID nvarchar(max),
    @IsSpanishLanguage int,    
    @ReturnCode nvarchar(max),
    @Request nvarchar(max) ,
    @Response nvarchar(max) , 
    @WSCancel bit,   
    @HasError int out,
    @Message nvarchar(max) out
)
as
begin try  
    declare @IdPureMinutes int
    declare @Status int    
    declare @TransactionCancelDate datetime= getdate() 
    set @HasError=0
    Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,6)   

    select @Status=case (@WSCancel) 
                when 1 then 2 
                else status end ,
                @IdPureMinutes=IdPureMinutes               
    from PureMinutesTransaction where IdProductTransfer=@IdProductTransfer
    
    if @Status=2 
    begin
        EXEC	[Operation].[st_UpdateProductTransferStatus]
		        @IdProductTransfer = @IdProductTransfer,
		        @IdStatus = 22,                
		        @TransactionDate = @TransactionCancelDate,
                @EnterByIdUser = @IdUser,
		        @HasError = @HasError OUTPUT        
    end    
    
        update PureMinutesTransaction set
            DateOfLastChange=getdate(),	                                
            CancelDateOfTransaction=getdate(),	                                
            LastReturnCode=@ReturnCode,
            Request=@Request,
            Response=@Response,
            PureMinutesUserID=@PureMinutesUserID,
            CancelIdUser=@IdUser,
            Status=@Status
        where IdProductTransfer=@IdProductTransfer        

        insert into PureMinutesResponseLog
        (IdPureMinutes,Date,Status,ReturnCode,Request,Response)
        values
        (@IdPureMinutes,getdate(),@Status,@ReturnCode,@Request,@Response)    

end try
begin catch
    Set @HasError=1                                                                                   
    Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,7)                                                                               
    Declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_CancelPureMinutesTransaction',Getdate(),@ErrorMessage)
end catch

