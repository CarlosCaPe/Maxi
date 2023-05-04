

CREATE procedure [dbo].[st_AgentBalanceDetail]
(              
    @IdAgent int,              
    @DateFrom datetime,               
    @DateTo datetime              
)
as             
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
<log Date="07/05/2022" Author="saguilar">Add with(nolock) Se limita a un dia el reporte</log>
<log Date="09/05/2022" Author="saguilar">Se limita a un dia el Reporte a 3 dias</log>
<log Date="11/05/2022" Author="saguilar">Se quita la limitante de dias para que se pueda consultar el rango de fechas seleccionado </log>
<log Date="02/09/2022" Author="saguilar" " Name="#1">Se agrega limitante temporal de 3 dias para la consulta del reporte </log>
<log Date="15/09/2022" Author="jdarellano" Name="#2">Adecuación para que tome limitante temporal de 3 dias para la consulta del reporte en días viernes, sábado y domingo (6, 7, y 1, respectivamente).</log>
<log Date="21/12/2022" Author="jdarellano" Name="#3">Adecuación para que tome limitante temporal de 5 dias para la consulta del reporte en días miércoles, y jueves (4 y 5, respectivamente).</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

IF (DATEPART(WEEKDAY,GETDATE()) IN (6,7,1))--#2
BEGIN
	IF DATEDIFF(DAY, @DateFrom, @DateTo) > 3 --#1
		SET @DateTo = DATEADD(DAY, 3, @DateFrom) --#1
END

ELSE IF (DATEPART(WEEKDAY,GETDATE()) IN (4,5))--#3
BEGIN
	IF DATEDIFF(DAY, @DateFrom, @DateTo) > 5 --#3
		SET @DateTo = DATEADD(DAY, 5, @DateFrom) --#3
END
       
Select @DateFrom=dbo.RemoveTimeFromDatetime(@DateFrom),@DateTo=dbo.RemoveTimeFromDatetime(@DateTo+1)              
Declare @BalanceForward money         
        
Select top 1         
    @BalanceForward=Balance         
from 
    AgentBalance  with(nolock)              
where 
    IdAgent= @IdAgent             
    and 
    DateOfMovement<@DateFrom              
Order by 
    DateOfMovement desc         
        
Select   
    0 IdAgentBalance,   
    '' as TypeOfMovement,@DateFrom as DateOfMovement,       
    '' as Reference,        
    'Balance Forward' as [Description],        
    '' as Country,        
    0 as Commission,    
    0 as FxFee,        
    '' as Credit,        
    '' as Debit,        
    ISNULL(@BalanceForward,0) as Balance, --CAMBIO JOSE 09/02/2015
    0 AmountForBalance
union            
Select    
    IdAgentBalance,     
    case when TypeOfMovement = 'CANC' and OldIdTransfer is not null then 'CANCM'
	ELSE TypeOfMovement end  TypeOfMovement,              
    DateOfMovement,              
    case 
        when isnull(Reference,'')='' then convert(varchar,IdAgentBalance)
        else Reference
    end    
    Reference,              
    CASE [TypeOfMovement]
    	WHEN 'TTU' THEN [Description] + ' - ' + [Country]
	    WHEN 'CTTU' THEN [Description] + ' - ' + [Country]
		WHEN 'RTTU' THEN [Description] + ' - ' + [Country]
		WHEN 'CRTTU' THEN [Description] + ' - ' + [Country]
	    WHEN 'LTTU' THEN [Description] + ' - ' + [Country]
	    WHEN 'CLTTU' THEN [Description] + ' - ' + [Country]
	    WHEN 'LD' THEN [Description]
	    WHEN 'LDC' THEN [Description]
	    WHEN 'LLD' THEN [Description] + ' - ' + [Country]
	    WHEN 'CLLD' THEN [Description] + ' - ' + [Country]
	    ELSE [Description] END [Description],
    CASE [TypeOfMovement]
	    WHEN 'TTU' THEN ''
	    WHEN 'CTTU' THEN ''
		WHEN 'RTTU' THEN ''
	    WHEN 'CRTTU' THEN ''
	    WHEN 'LTTU' THEN ''
	    WHEN 'CLTTU' THEN ''
	    WHEN 'LD' THEN '' 
	    WHEN 'LDC' THEN '' 
	    WHEN 'LLD' THEN '' 
	    WHEN 'CLLD' THEN '' 
	    ELSE [Country] END [Country],              
    Commission,      
    FxFee,            
    Case 
        when DebitOrCredit='Credit' Then Amount else '' end 
    as Credit,              
    Case 
        when DebitOrCredit='Debit' Then Amount else '' end 
    as Debit,              
    isnull(Balance,0) as Balance,
    case 
        when DebitOrCredit='Debit' Then Amount else Amount*(-1) end 
    AmountForBalance
from 
    AgentBalance WITH(NOLOCK)
	left join TransferModify  m WITH(NOLOCK) on idTransfer = m.OldIdTransfer	              
where 
    IdAgent=@IdAgent              
    and 
    DateOfMovement>=@DateFrom and DateOfMovement<@DateTo              
Order by 
    DateOfMovement asc, IdAgentBalance asc
