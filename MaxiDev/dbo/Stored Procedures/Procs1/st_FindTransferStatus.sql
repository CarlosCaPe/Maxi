CREATE procedure [dbo].[st_FindTransferStatus]          
    @IdTransfer int
as    

--create table #tmp
--(
--    IdTransfer int,	   
--    Semaphore nvarchar(max),	
--    IdStatus int
--)
    
--insert into #tmp
select * from
(
  select    
   T.IdTransfer,       
   dbo.fun_GetTransferHoldSemaphore(T.IdTransfer) as Semaphore,   
   t.IdStatus
  FROM [dbo].[Transfer] T (nolock)
   left join [TransferSSN] ssn  (nolock) on T.IdTransfer=ssn.IdTransfer
   where         
   t.idtransfer=isnull(@IdTransfer,t.idtransfer)
union    
    
  select    
   T.IdTransferClosed IdTransfer,      
   '0|0|0' as Semaphore,   
   t.IdStatus   
  FROM [dbo].TransferClosed T (nolock)      
     left join [TransferSSN] ssn  (nolock) on T.IdTransferClosed=ssn.IdTransfer
   where     
   t.IdTransferClosed=isnull(@IdTransfer,t.IdTransferClosed)

) t

--select 	IdTransfer,Semaphore,IdStatus from #tmp

/****************************************************************************/