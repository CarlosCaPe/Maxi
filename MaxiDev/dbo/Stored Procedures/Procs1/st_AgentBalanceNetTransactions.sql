CREATE procedure [dbo].[st_AgentBalanceNetTransactions]
(
    @IdAgent int,
    @DateFrom datetime,
    @DateTo datetime
)
As
/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description>/Description>

<ChangeLog>
<log Date="15/02/2018" Author="snevarez">Ticket 925: Numero negativo en reporte(AgentBalance.rdl -> DataSet : NetTransaction)</log>
<log Date="20/03/2018" Author="jmmolina"> Se elimino regla aplicada por ticket 925 y se agrego validación cuando el resultado sea negativo asigne un cero #1</log>
</ChangeLog>
*********************************************************************/
Set Nocount on


/*Insert TRAN,CANC,REJ of AgentBalance in #temp*/
Select @DateFrom=dbo.RemoveTimeFromDatetime(@DateFrom)
	   ,@DateTo=dbo.RemoveTimeFromDatetime(@DateTo+1);

Select
	   TypeOfMovement,
	   Amount,
	   Country,
	   DebitOrCredit,
	   Balance
    Into #temp
From AgentBalance WITH(NOLOCK)
    Where IdAgent=@IdAgent 
	   And DateOfMovement>=@DateFrom 
	   And DateOfMovement<@DateTo 
	   And TypeOfMovement in ('TRAN','CANC','REJ');


/*Insert CGO and Commission!=0 of AgentBalance in #temp*/
INSERT INTO #temp
    SELECT
	   'TRAN',
	   Amount,
	   Country,
	   DebitOrCredit,
	   Balance
    FROM AgentBalance with(nolock)
	   WHERE IdAgent=@IdAgent 
		  AND DateOfMovement>=@DateFrom 
		  AND DateOfMovement<@DateTo AND TypeOfMovement in ('CGO') 
		  AND Commission!=0;


/*Insert Count TRAN by Country of #temp in #Canc*/
Select 
	   Country
	   ,count(1) as TotalTransfer
    Into #Tran
From #temp
    Where TypeOfMovement='TRAN'
Group by Country;


/*Insert Count CANC by Country of #temp in #Canc*/
Select 
    @DateFrom=dbo.RemoveTimeFromDatetime(@DateFrom)
    ,@DateTo=dbo.RemoveTimeFromDatetime(@DateTo+1);

Select 
	   Country
	   ,count(1) as TotalCancel
    Into #Canc
From #temp
    Where TypeOfMovement='CANC'
Group by Country;


/*Insert Count REJ by Country of #temp in #Rej*/
Select 
    @DateFrom=dbo.RemoveTimeFromDatetime(@DateFrom)
    ,@DateTo=dbo.RemoveTimeFromDatetime(@DateTo+1);

Select 
	   Country
	   ,count(1) as TotalRejected
    Into #Rej
From #temp
    Where TypeOfMovement='REJ'
Group by Country;


/*Insert distinct Country of #temp in #Base*/
Select distinct 
    country
    ,0 as Num 
	   Into #Base 
From #Temp 
    Where country<>'';


/*Results*/
Select 
    A.Country
    --,isnull(B.TotalTransfer,0)-isnull(C.TotalCancel,0)-isnull(D.TotalRejected,0) as Number
	,CASE WHEN isnull(B.TotalTransfer,0)-isnull(C.TotalCancel,0)-isnull(D.TotalRejected,0) < 0 THEN 0 ELSE isnull(B.TotalTransfer,0)-isnull(C.TotalCancel,0)-isnull(D.TotalRejected,0) END as Number --#1
    --,isnull(B.TotalTransfer,0) as Number /*Ticket 925*/
From #Base A
    full Join #Tran B on (A.Country=B.Country)
    full Join #Canc C on (C.Country=A.Country)
    full Join #Rej D on (D.Country=A.Country)
Order by B.Country;
