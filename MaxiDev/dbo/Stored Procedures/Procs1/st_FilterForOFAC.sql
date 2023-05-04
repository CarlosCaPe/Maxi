CREATE  procedure [dbo].[st_FilterForOFAC]                                
(                                
    @StartDate datetime,                                
    @EndDate datetime,
    @HasError bit output,                  
    @Message nvarchar(max) output     
)
as

Begin Try 

declare @Total int
declare @tot1 int
declare @tot2 int

                        
set @EndDate=dbo.RemoveTimeFromDatetime(@EndDate+1)                        
set @StartDate=dbo.RemoveTimeFromDatetime(@StartDate) 



Select @tot1=Count(1)
       From [Transfer] T with(nolock)
       inner join [Agent] A with(nolock) on T.IdAgent = A.IdAgent
       inner join [Customer] C with(nolock) on T.IdCustomer = C.IdCustomer
       inner join [Payer] P with(nolock) on T.IdPayer = P.IdPayer
       inner join [Status] S with(nolock) on T.IdStatus = S.IdStatus
       Where 
            ((t.idtransfer in (select idtransfer from transferdetail where idstatus=15) and t.IdStatus not in (41)) or (t.idtransfer in (select idtransfer from transferdetail where idstatus=16)))
            and 
            t.DateOfTransfer>=@StartDate and t.dateoftransfer<@EndDate
       
       
Select @tot2=count(1)
       From [TransferClosed] T with(nolock)
       inner join [Agent] A with(nolock) on T.IdAgent = A.IdAgent
       inner join [Customer] C with(nolock) on T.IdCustomer = C.IdCustomer
       inner join [Payer] P with(nolock) on T.IdPayer = P.IdPayer
       inner join [Status] S with(nolock) on T.IdStatus = S.IdStatus
       Where 
            ((t.idtransferclosed in (select idtransferclosed from transfercloseddetail where idstatus=15) and t.IdStatus not in (41)) or (t.idtransferclosed in (select idtransferclosed from transfercloseddetail where idstatus=16)))
            and 
            t.DateOfTransfer>=@StartDate and t.dateoftransfer<@EndDate


set @Total = isnull(@tot1,0) + isnull(@tot2,0)

/*
If @Total =0                   
Begin                  
   Select @Message =dbo.GetMessageFromLenguajeResorces (0,36)                   
   Set @HasError=1                
   Return                  
End  
*/

If @Total <= 3000                   
Begin                  
   Select @Message =dbo.GetMessageFromLenguajeResorces (0,35)                   
   Set @HasError=0 
select top 1500 * from (
Select T.IdAgent,  A.AgentCode, T.ClaimCode, T.CustomerName, T.CustomerFirstLastName, T.CustomerSecondLastName,
                     A.AgentName, T.DateOfTransfer, T.IdTransfer, T.Folio, P.PayerName, T.AmountInDollars, T.IdStatus, S.StatusName,
                     C.PhysicalIdCopy as CustomerPhysicalIdCopy, T.ReviewDenyList, T.ReviewOfac, T.ReviewKyc, T.ReviewGateway, T.ReviewReturned,
                     T.IdBeneficiary, T.IdCustomer--, NULL as LastReview
                     ,Convert(bit,0) HasFiles,
                     0 releasedCount,
                     isnull((select top 1 1 from TransferOFACInfo where idtransfer=t.idtransfer),0) ShowOfacInfo
       From [Transfer] T with(nolock)
       inner join [Agent] A with(nolock) on T.IdAgent = A.IdAgent
       inner join [Customer] C with(nolock) on T.IdCustomer = C.IdCustomer
       inner join [Payer] P with(nolock) on T.IdPayer = P.IdPayer
       inner join [Status] S with(nolock) on T.IdStatus = S.IdStatus
      Where 
            ((t.idtransfer in (select idtransfer from transferdetail where idstatus=15) and t.IdStatus not in (41)) or (t.idtransfer in (select idtransfer from transferdetail where idstatus=16)))
            and 
            t.DateOfTransfer>=@StartDate and t.dateoftransfer<@EndDate
       
union all
Select T.IdAgent,  A.AgentCode, T.ClaimCode, T.CustomerName, T.CustomerFirstLastName, T.CustomerSecondLastName,
                     A.AgentName, T.DateOfTransfer, T.IdTransferclosed idtransfer, T.Folio, P.PayerName, T.AmountInDollars, T.IdStatus, S.StatusName,
                     C.PhysicalIdCopy as CustomerPhysicalIdCopy, T.ReviewDenyList, T.ReviewOfac, T.ReviewKyc, T.ReviewGateway, T.ReviewReturned,
                     T.IdBeneficiary, T.IdCustomer--, NULL as LastReview
                     ,Convert(bit,0) HasFiles,
                     0 releasedCount,
                     isnull((select top 1 1 from TransferOFACInfo where idtransfer=t.idtransferclosed),0) ShowOfacInfo
       From [TransferClosed] T with(nolock)
       inner join [Agent] A with(nolock) on T.IdAgent = A.IdAgent
       inner join [Customer] C with(nolock) on T.IdCustomer = C.IdCustomer
       inner join [Payer] P with(nolock) on T.IdPayer = P.IdPayer
       inner join [Status] S with(nolock) on T.IdStatus = S.IdStatus
      Where 
            ((t.idtransferclosed in (select idtransferclosed from transfercloseddetail where idstatus=15) and t.IdStatus not in (41)) or (t.idtransferclosed in (select idtransferclosed from transfercloseddetail where idstatus=16)))
            and 
            t.DateOfTransfer>=@StartDate and t.dateoftransfer<@EndDate
) t
Order by T.DateOfTransfer desc
end
Else                   
Begin                  
    Select @Message =dbo.GetMessageFromLenguajeResorces (0,34)                   
 Set @HasError=1                  
End 

End Try                                                      
Begin Catch                  
 Set @HasError=1                                                      
 Declare @ErrorMessage nvarchar(max)                                                       
 Select @ErrorMessage=ERROR_MESSAGE()           
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_FilterForOFAC',Getdate(),@ErrorMessage)                                                      
End Catch  
