CREATE PROCEDURE [Corp].[st_GetSchemaBillersByIdAgent_BillPayment]
(
    @idagent int,   
    @idAggregator int, 
    @IdLenguage int,    
    @idUser int,
    @HasError int out,
    @Message nvarchar(max) out
) 
 
as
 /********************************************************************
<Author></Author>
<app>MaxiAgente</app>
<Description></Description>

<ChangeLog>
<log Date="10/08/2018" Author="snevarez">Creacion del Store</log>
<log Date="24/09/2018" Author="snevarez">Update Logs</log>
<log Date="24/09/2018" Author="azavala">Add filter to show only enable billers for state</log>
</ChangeLog>
*********************************************************************/
begin try

--Exec BillPayment.st_GetSchemaBillersByIdAgent 1240,1,1,0,'',''
--declare @idagent int = 488
--declare @idAggregator int = 1

--Insert Into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage) values ('BillPayment.st_GetSchemaBillersByIdAgent', GETDATE(),'@idagent: ' + CONVERT(varchar(MAX),@idagent)+ ' @idAggregator: ' + CONVERT(varchar(MAX),@idAggregator)+ ' @IdLenguage: ' + CONVERT(varchar(MAX),@IdLenguage)+ ' @idUser: ' + CONVERT(varchar(MAX),@idUser)) 
    declare  @idState int
    declare @StateCode varchar(5)
    set @Message='Successful query';

    set @HasError = 0;

    select 
	   @StateCode = AgentState 
    from 
	   Agent WITH (NOLOCK)
    where
	   IdAgent= @idagent;

    select @idState = idState from State WITH (NOLOCK) where StateCode=@StateCode;

    Select 
		'Agent',
		B.IdAggregator,
		B.Name,
		A.IdBiller,
		A.IdAgent,
		A.IdFee,
		F.FeeName,
		A.IdCommission,
		C.CommissionName,
		A.CommionSpecial,
		A.DateForCommision,
		B.IdStatus
	from BillPayment.AgentForBillers A WITH (NOLOCK)
	    inner join BillPayment.Billers B WITH (NOLOCK) on B.IdBiller = A.IdBiller
	    inner join FeeByOtherProducts F WITH (NOLOCK) on F.IdFeeByOtherProducts = A.IdFee
	    inner join CommissionByOtherProducts C WITH (NOLOCK) on C.IdCommissionByOtherProducts = A.IdCommission
	where B.IdAggregator = @idAggregator
	   and IdAgent = @idagent

    union 

	Select 
		'State',
		B.IdAggregator,
		B.Name,
		S.IdBiller,
		@idagent IdAgent,
		S.IdFee,
		F.FeeName,
		S.IdCommission,
		C.CommissionName,
		0 CommionSpecial,
		null DateForCommision,
		B.IdStatus		 
	from BillPayment.StateForBillers S WITH (NOLOCK)
	    inner join BillPayment.Billers B WITH (NOLOCK) on B.IdBiller = S.IdBiller
	    inner join FeeByOtherProducts F WITH (NOLOCK) on F.IdFeeByOtherProducts = S.IdFee
	    inner join CommissionByOtherProducts C WITH (NOLOCK) on C.IdCommissionByOtherProducts = S.IdCommission
	where B.IdAggregator = @idAggregator
	and S.IdState = @idState
	and S.IdBiller not in (Select C.IdBiller from BillPayment.AgentForBillers C WITH (NOLOCK) where C.IdAgent = @idagent)
	and S.IDStatus=1
	order by IdBiller;

	Insert into ErrorLogForStoreProcedure(StoreProcedure,ErrorDate,ErrorMessage)
	   Values('Corp.st_GetSchemaBillersByIdAgent_BillPayment'
			,Getdate()
		     , 'select ok');

End Try


Begin Catch 

    set @HasError = 1
    DECLARE @ErrorLine INT = ERROR_LINE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
    Select @Message=ERROR_MESSAGE();
    Insert into Soporte.InfoLogForStoreProcedure(StoreProcedure,InfoDate,InfoMessage)
	   Values('Corp.st_GetSchemaBillersByIdAgent_BillPayment'
			,Getdate()
		     , @Message + ' occurred at Line_Number: ' + CAST(ERROR_LINE() AS VARCHAR(50)) + ' with parameters IdAgent:' + CAST(@idagent AS VARCHAR(12)) + 'IidAggregator:' + CAST(@idAggregator AS VARCHAR(12)));

End Catch
