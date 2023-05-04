CREATE PROCEDURE [Corp].[st_GetTransfersHoldWithFileReserved]  
(  
 @IdUser INT, 
 @IdTransfer INT  	
)

as
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;  
set ARITHABORT on;



if object_id(N'tempdb.dbo.#temp1', N'U') is not null

begin
	drop table #temp1;
end

if object_id(N'tempdb.dbo.#temp2', N'U') is not null

begin
	drop table #temp2;
end
if object_id(N'tempdb.dbo.#tempAllTrans', N'U') is not null

begin
	drop table #tempAllTrans;
end
    
declare
 @TransPendientes int
 , @TiempoAsginado int



	declare @IdTransactionReceiptType int     
	set  @IdTransactionReceiptType=55
	

	select 
	 @TiempoAsginado = cast(Value as int)
	from 
	 GlobalAttributes with(nolock)
	where Name ='PhoneHoldExpress'
	
  
	
	
begin
	select 
    	T.IdAgent
    	, A.AgentCode
    	, T.ClaimCode
    	, T.CustomerName
    	, T.CustomerFirstLastName
    	, T.CustomerSecondLastName
    	, A.AgentName
    	, T.DateOfTransfer
    	, T.IdTransfer
    	, T.Folio
    	, P.PayerName
    	, T.AmountInDollars
    	, T.IdStatus
    	, [StatusName] = 
    	              ( select
			             StatusName
			            from 
			              dbo.[Status] with(nolock)
			            where 
			             idStatus=T.idStatus
			           )
    	, C.PhysicalIdCopy
    	, C.IdCustomer
       into #temp1
	 from 
	  [transfer] T with(nolock)
	 join
	  Agent A with(nolock) 
	 on 
	  A.IdAgent = T.IdAgent
	 join  
	  Payer P with(nolock) 
	 on 
	  P.IdPayer = T.IdPayer
	 join 
	  Customer C with(nolock) 
	 on 
	  C.IdCustomer = T.IdCustomer
	 join 
	  TransferHolds H with(nolock) 
	 on 
	  H.IdTransfer = T.IdTransfer
	  and H.IdStatus= 3 
	  and H.IsReleased is null
	  
	 left join 
	  UploadFiles UC with(nolock) 
	 on 
	  UC.IdUploadFile =
	                 (select 
	                   MAX(IdUploadFile) 
	                  from 
	                   UploadFiles with(nolock) 
	                  where 
	                   IdDocumentType=@IdTransactionReceiptType 
	                   and IdReference = T.IdTransfer 
	                   and IdStatus = 1
	                  )     
	 where 
	  T.IdStatus=41 
	  
		  
    select 
     distinct IdReference
     , max(IdUploadFile) over(partition by IdReference) IdUploadFile 
      into #temp2 
     from 
      UploadFiles with(nolock)       
     where 
      IdDocumentType=@IdTransactionReceiptType 
      and IdStatus = 1 
      and IdReference in (select 
      				        idtransfer 
      				      from  
      				       #temp1
      				      ) 
    

      select 
	     t1.IdTransfer
	     , [IdUser] = @IdUser 
	     , [DateOfReserved] = getdate()
	     , [IdStatusReserved] = 1
	     , [IdUploadFile]  =  UC.IdUploadFile
	     , [FilePath] = UC.FileGuid + UC.Extension   
	     , t1.Folio
	     , t1.AgentCode
	     , t1.AgentName
	     , t1.IdStatus
         , t1.DateOfTransfer
	    into #tempAllTrans
	    from 
	     #temp1 t1
	    left join 
	     #temp2 t2 
	    on 
	     t1.idtransfer=t2.IdReference
	    inner join 
	     UploadFiles UC with(nolock) 
	    on 
	     UC.IdUploadFile=t2.IdUploadFile
	    order by t1.DateOfTransfer asc
	    
 	 select 
	  @TransPendientes=count(*) 
	 from 
	   #tempAllTrans
	 	    
-- select @TransPendientes	 	    
	 	    
end

begin    
  
   delete
    TransferByHoldReserved
   where     
	(select 
	     datediff (minute 
	              , TransferByHoldReserved.DateOfReserved 
	              , getdate() 
	             )      
	    ) > @TiempoAsginado ;
	          

   delete
    TransferByHoldReserved
   where      
     IdUser=@IdUser;
        
 declare 
  @IdTransfertemp int 
  ,	@iduploadfile int
  ,	@filepath     nvarchar(100)
  ,	@Folio            int 
  ,	@AgentCode        nvarchar(20) 
  ,	@AgentName 	     nvarchar(20) 
  , @IdStatus		int 

IF @idTransfer = 0 BEGIN 

		while exists (select 1 from #tempAllTrans)
		 begin
			select top 1
			  @IdTransfertemp = IdTransfer 
			  , @iduploadfile = IdUploadFile
			  , @filepath     = filepath 
			  ,	@Folio        = Folio 
		 	  ,	@AgentCode    = AgentCode
		 	  ,	@AgentName 	  = AgentName
		 	  , @IdStatus = IdStatus
		 
			from  
			 #tempAllTrans
		   order by DateOfTransfer
		   
		    if not exists 
			  (     
			     select 
			      IdTransfer 
			     from 
			      TransferByHoldReserved with(nolock)
			     where 
			 IdTransfer = @IdTransfertemp 
			   )    
		      begin 
		        insert  into dbo.TransferByHoldReserved
						(
						IdTransfer
						, IdUser
						, DateOfReserved
						, IdStatusReserved
						, IdUploadFile
						, FilePath
						, Folio
						, AgentCode
						, AgentName
						, IdStatus	 
						)
					values 
						(
						@IdTransfertemp
						, @IdUser
						, getdate()
						, 1
						, @iduploadfile
						, @filepath
						, @Folio       
						, @AgentCode   
						, @AgentName 
						, @IdStatus	 
						 
						);
		       end 
		    else
		       begin      
				    if exists 
				          (     
						     select 
						      IdTransfer 
						     from 
						      TransferByHoldReserved with(nolock)
						     where 
						      IdTransfer = @IdTransfertemp 
						      and IdStatusReserved=0
					       )
					     begin 
					         update 
						      TransferByHoldReserved
						      set 
						       IdStatusReserved = 1
						       , DateOfReserved = getdate()
						       , IdUser 		= @IdUser 
						       , IdUploadFile	= @iduploadfile		       
						       , filePath		= @filepath
						      where 
				                IdTransfer = @IdTransfertemp ;
					     end
			     end                   
		    delete  
		     #tempAllTrans 
		    where  
		     IdTransfer = @IdTransfertemp
		    if (select count(1) from TransferByHoldReserved with(nolock) where IdUser = @IdUser and IdStatusReserved = 1) > 5
		      break          
		   end
		
		    
		 select 
		    Res.idReserved
			, Res.IdTransfer
			, Res.IdUser
			, Res.Folio
			, Res.AgentCode
			, Res.AgentName
			, Res.DateOfReserved
			, Res.IdStatusReserved
			, Res.IdUploadFile
			, Res.FilePath
			, Res.IdStatus
		    , @TransPendientes as Pendientes
		    , @TiempoAsginado as TiempoHoldExpress
		   from 
		    TransferByHoldReserved Res with(nolock)
		--   inner join 
		--    #temp2 temp
		--   on 
		--     temp.IdReference= Res.IdTransfer            
		   where 
		    Res.IdUser		 		    =  @IdUser
		   -- and Res.IdStatusReserved	=  1
		    
  END ELSE BEGIN 
  	  
	
--	INSERT INTO dbo.TransferByHoldReserved (IdTransfer, IdUser, Folio, AgentCode, AgentName, DateOfReserved, IdStatusReserved, IdUploadFile, FilePath, IdStatus)
--  	SELECT IdTransfer,@idUser,folio,agentCode,AgentName,dateadd(minute,@TiempoAsginado,getDate()),1,IdUploadFile,filePath,idStatus FROM #tempAllTrans WHERE idTransfer=@idTransfer
--	

		select top 1
			  @IdTransfertemp = IdTransfer 
			  , @iduploadfile = IdUploadFile
			  , @filepath     = filepath 
			  ,	@Folio        = Folio 
		 	  ,	@AgentCode    = AgentCode
		 	  ,	@AgentName 	  = AgentName
		 	  , @IdStatus   = IdStatus
		 
			from  
			 #tempAllTrans
			WHERE idTransfer=@idTransfer
	
	
	            insert  into dbo.TransferByHoldReserved
						(
						IdTransfer
						, IdUser
						, DateOfReserved
						, IdStatusReserved
						, IdUploadFile
						, FilePath
						, Folio
						, AgentCode
						, AgentName
						, IdStatus	 
						)
					values 
						(
						@IdTransfertemp
						, @IdUser
						, getdate()
						, 1
						, @iduploadfile
						, @filepath
						, @Folio       
						, @AgentCode   
						, @AgentName 
						, @IdStatus	 
						 
						);
		        

	SELECT 
	IdTransfer
	, idReserved
	, IdUser
	, Folio
	, AgentCode
	, AgentName
	, DateOfReserved
	, IdStatusReserved
	, IdUploadFile
	, FilePath
	, IdStatus
	, @TransPendientes as Pendientes
    , @TiempoAsginado as TiempoHoldExpress
 FROM TransferByHoldReserved with(nolock) WHERE IdUser =@idUser
  
  END 
end 	    




