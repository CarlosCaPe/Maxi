CREATE Procedure [dbo].[st_GetUnclaimedTransfersForce]                                  
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
	
Begin Try                                                                            
	Declare @DaysBeforeUnclaimed Int   
	Declare @Today Date   
	Create Table #UnclaimedT                  
	(                  
		IdTransfer int,              
		Processed bit                  
	);  
	
	                                       
	Select @DaysBeforeUnclaimed=Convert(int,Value) From GlobalAttributes with(nolock) where Name='TimeBeforeUnclaimedHold'                              
	set @Today= DATEADD(day,-@DaysBeforeUnclaimed, GETDATE())

	Insert TransfersUnclaimed (IdTransfer, IdStatus)
	select t.IdTransfer,1 from TransfersUnclaimed u with(nolock)
	right join [Transfer] t with(nolock) on t.IdTransfer = u.IdTransfer   where t.idtransfer in
	(
		26233795
	);

--Begin Tran
	Insert into #UnclaimedT
	select t.IdTransfer, 0
	From [Transfer] t with(nolock) inner join 
	TransfersUnclaimed u with(nolock) on t.IdTransfer=u.IdTransfer
	Where u.IdStatus=1 and t.IdStatus=23;
	Declare @idTrans int;
	
	While Exists (Select 1 from #UnclaimedT where Processed=0)   
	Begin 
		Select top 1 @idTrans= IdTransfer
		from #UnclaimedT where Processed=0;
		
		Update [Transfer] set IdStatus= 25, DateStatusChange= GETDATE()---Cancel Stand By
		From [Transfer] t inner join TransfersUnclaimed u on t.IdTransfer=u.IdTransfer
		Where u.IdStatus=1 and t.IdTransfer= @idTrans;
		
		Exec st_SaveChangesToTransferLog @idTrans,25,'Cancel Stand By',0;
		
		Update #UnclaimedT set Processed=1 where IdTransfer=@idTrans;
	End

	
--Commit

End Try
Begin Catch

 --if (@@TRANCOUNT > 0)
 --begin
 --   rollback
 --end
                                                                                          
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_GetUnclaimedTransfers',Getdate(),ERROR_MESSAGE());    

End Catch
