CREATE PROCEDURE [dbo].[st_GetUnclaimedTransfers]                                  
as                                  
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
<log Date="27/01/2021" Author="cagarcia"> Se agrega logica para tomar envios en estatus Returned para cambiarlos a Unclaimed Hold si llevan 30 dias en ese estatus</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;
	
Begin Try                                                                            
declare @Idgateway int,
		@TimeBeforeUnclaimedHold int,
		@Today Date

	create table #Gateway
	(
		Idgateway int,
		TimeBeforeUnclaimedHold int
	);

	Create Table #UnclaimedForGateway                  
	(                  
		IdTransfer int,              
		IdStatus int                  
	);
	
	Create Table #UnclaimedT                  
	(                  
		IdTransfer int,              
		Processed bit                  
	);
  
INSERT INTO #UnclaimedForGateway	
SELECT T.IdTransfer, 1
FROM TransfersUnclaimed U WITH(NOLOCK) RIGHT JOIN
	Transfer T WITH(NOLOCK) ON T.IdTransfer = U.IdTransfer
WHERE T.DateStatusChange <= DATEADD(day,-30, GETDATE()) and T.IdStatus = 24;

INSERT INTO TransfersUnclaimed (IdTransfer, IdStatus)
SELECT IdTransfer, IdStatus FROM #UnclaimedForGateway;

INSERT INTO #UnclaimedT
SELECT t.IdTransfer, 0
FROM [Transfer] t WITH(nolock) INNER JOIN 
	TransfersUnclaimed u WITH(nolock) ON t.IdTransfer=u.IdTransfer
WHERE u.IdStatus = 1 AND t.IdStatus = 24;

DECLARE @IdTransReturned INT

WHILE EXISTS (SELECT 1 FROM #UnclaimedT WHERE Processed = 0)   
BEGIN
	SELECT TOP 1 @IdTransReturned = IdTransfer
	FROM #UnclaimedT WHERE Processed = 0;
	
	UPDATE [Transfer] SET IdStatus = 27, DateStatusChange = GETDATE()---Unclaimed Hold
	From [Transfer] t inner join TransfersUnclaimed u on t.IdTransfer = u.IdTransfer
	Where u.IdStatus = 1 and t.IdTransfer = @IdTransReturned;
	
	Exec st_SaveChangesToTransferLog @IdTransReturned, 27, 'Unclaimed Hold', 0;
	
	Update #UnclaimedT set Processed=1 where IdTransfer=@IdTransReturned;
END
	                                       
DELETE FROM #UnclaimedT
DELETE FROM #UnclaimedForGateway
	
insert into #Gateway
select Idgateway,TimeBeforeUnclaimedHold from gateway with(nolock) where [status]=1

insert into #UnclaimedForGateway
	select 
		t.IdTransfer,1 
	from 
		TransfersUnclaimed u with(nolock) 
	right join 
		[Transfer] t with(nolock) on t.IdTransfer = u.IdTransfer  
	where 
		Idgateway=3 and idpayer in (select idpayer from payer with(nolock) where PayerCode='EK6') and DateStatusChange <= DATEADD(day,-29, GETDATE()) and t.IdStatus=23;  --Estatus PaymentReady

while exists(select 1 from #Gateway)
begin 
	select top 1 @Idgateway=Idgateway,@TimeBeforeUnclaimedHold=TimeBeforeUnclaimedHold from #Gateway;

	set @Today= DATEADD(day,-@TimeBeforeUnclaimedHold, GETDATE())

	insert into #UnclaimedForGateway
	select 
		t.IdTransfer,1 
	from 
		TransfersUnclaimed u with(nolock) 
	right join 
		[Transfer] t with(nolock) on t.IdTransfer = u.IdTransfer  
	where 
		Idgateway=@Idgateway and DateStatusChange <= @Today and t.IdStatus=23 ; --Estatus PaymentReady

	delete from #Gateway where Idgateway=@Idgateway;
end

Insert TransfersUnclaimed (IdTransfer, IdStatus)
select IdTransfer, IdStatus from #UnclaimedForGateway;


	Insert into #UnclaimedT
	select t.IdTransfer, 0
	From [Transfer] t with(nolock) inner join 
	TransfersUnclaimed u with(nolock) on t.IdTransfer=u.IdTransfer
	Where u.IdStatus=1 and t.IdStatus=23;
	Declare @idTrans int
	
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

End Try
Begin Catch
                                                                                          
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_GetUnclaimedTransfers',Getdate(),ERROR_MESSAGE())    

End Catch
