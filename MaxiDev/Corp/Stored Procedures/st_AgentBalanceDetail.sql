/********************************************************************
<Author></Author>
<app></app>
<Description>Reporte Detallado del Balance</Description>

<ChangeLog>
<log Date="30/03/2023" Author="jfresendiz">BM-518 Se hace diferenciación para mostrar los ADV </log>
</ChangeLog>
*********************************************************************/
CREATE procedure [Corp].[st_AgentBalanceDetail]
(              
    @IdAgent int,              
    @DateFrom datetime,               
    @DateTo datetime              
)
as             
SET NOCOUNT ON;     

Select @DateFrom=dbo.RemoveTimeFromDatetime(@DateFrom),@DateTo=dbo.RemoveTimeFromDatetime(@DateTo+1)              
Declare @BalanceForward money        
        
Select top 1         
    @BalanceForward=Balance         
from 
    AgentBalance with(nolock)              
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
	CASE 
		WHEN [Description] = 'Wells Fargo Sub Account' THEN 'ADV'
		ELSE TypeOfMovement END TypeOfMovement,          
    DateOfMovement,              
    case 
        when isnull(Reference,'')='' then convert(varchar,IdAgentBalance)
        else Reference
    end    
    Reference,              
    CASE [TypeOfMovement]
    	WHEN 'TTU' THEN [Description] +' - ' + [Country]
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
    AgentBalance with(nolock)             
where 
    IdAgent=@IdAgent              
    and 
    DateOfMovement>=@DateFrom and DateOfMovement<@DateTo              
Order by 
    DateOfMovement asc, IdAgentBalance asc

