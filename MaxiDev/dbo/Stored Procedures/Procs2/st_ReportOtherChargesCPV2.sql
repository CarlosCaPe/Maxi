
CREATE procedure [dbo].[st_ReportOtherChargesCPV2]
(
        @StartDate datetime,
		@EndDate datetime,
        @IdAgent int,
        /*@IdLenguage int,*/
        @IsExcel bit,
        @PageIndex INT = 1,
	    @PageSize INT = 10,    
	    @columOrdering NVARCHAR(MAX)= NULL,
	    @order NVARCHAR(MAX) = NULL,
	    @PageCount INT OUTPUT/*,
        @HasError bit output,            
        @Message nvarchar(max) output*/
)
as
/*
set @HasError=0
set @Message ='Ok'
*/
Select @EndDate=dbo.RemoveTimeFromDatetime(@EndDate+1)                
Select @StartDate=dbo.RemoveTimeFromDatetime(@StartDate)
SET  @PageIndex=@PageIndex-1
/*
            select 
                   @PageCount = count(1)
	            from AgentCollectionDetail ACD 
                inner join 
	                AgentCollection AC on AC.IdAgentCollection = ACD.IdAgentCollection 
                inner join
	            AgentCollectionConcept ACC on ACC.IdAgentCollectionConcept = ACD.IdAgentCollectionConcept
                join agent a on a.idagent=ac.idagent
                join users u on u.iduser=ACD.enterbyiduser

            where ACD.DateofLastChange >=dbo.RemoveTimeFromDatetime(@StartDate) and ACD.DateofLastChange <dbo.RemoveTimeFromDatetime(@EndDate)
                and ACD.AmountToPay!=0
                and a.IdAgent=isnull(@IdAgent,a.idagent)   
*/     

create table #result2
(
    Id int IDENTITY (1,1),
    AgentCode nvarchar(max),
    IdMoveHistory int,     
    Concept nvarchar(max), 
    AmountToPay money, 
    ActualAmountToPay money, 
    LastAmountToPay money,     
    Note nvarchar(max),
    UserName nvarchar(max), 
    DateofLastChange datetime, 
    IsCollectPlan nvarchar(max), 
    DebitOrCredit nvarchar(max)
)

create table #OUTPUT
(
    Id int IDENTITY (1,1),
    AgentCode nvarchar(max),
    IdMoveHistory int,     
    Concept nvarchar(max), 
    AmountToPay money, 
    ActualAmountToPay money, 
    LastAmountToPay money,     
    Note nvarchar(max),
    UserName nvarchar(max), 
    DateofLastChange datetime, 
    IsCollectPlan nvarchar(max), 
    DebitOrCredit nvarchar(max)
)

/*
if ((isnull(@PageCount,0)=0) and @IsExcel=0)
begin
    set @HasError=1
    set @Message=replace(replace([dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SEARCHNOFOUND'),'Transfers','Match'),'transferencias','coincidencias')
end
else
begin
    if (@PageCount>3000) and (@IsExcel=0)
    begin
        set @HasError=1
        set @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SEARCHERROR')     
    end
    else
        begin          

            insert into #result2
            select 
                    A.AgentCode,
                    ACD.IdAgentCollectionDetail as IdMoveHistory, 
                    --ACC.Name as Concept, 
                    'CP' as Concept, 
                    round(case when ACD.AmountToPay>0 then 1 else -1 end * ACD.AmountToPay,2) AmountToPay, 
                    round(ACD.ActualAmountToPay,2) ActualAmountToPay, 
                    round(ACD.LastAmountToPay,2) LastAmountToPay, 
                    case when ACD.LastAmountToPay=0 
                        then 'Collect Plan Creation' +
                            case when isnull(ACD.Note ,'')='' then '' else ' - '+ACD.Note end
                        else ACD.Note 
                    end
                    note,
                    username, 
                    ACD.DateofLastChange, 
                    case when ACD.LastAmountToPay=0 then 'Collect Plan Creation' else '' end IsCollectPlan, 
                    case when ACD.LastAmountToPay-ACD.ActualAmountToPay<0 then 'Debit' else 'Credit' end DebitOrCredit
	            from AgentCollectionDetail ACD 
                inner join 
	                AgentCollection AC on AC.IdAgentCollection = ACD.IdAgentCollection 
                inner join
	            AgentCollectionConcept ACC on ACC.IdAgentCollectionConcept = ACD.IdAgentCollectionConcept
                join agent a on a.idagent=ac.idagent
                join users u on u.iduser=ACD.enterbyiduser

            where ACD.DateofLastChange >=dbo.RemoveTimeFromDatetime(@StartDate) and ACD.DateofLastChange <dbo.RemoveTimeFromDatetime(@EndDate)
                and ACD.AmountToPay!=0
                and a.IdAgent=isnull(@IdAgent,a.idagent)
            --order by A.AgentCode,ACD.DateofLastChange 

        
    end
end
*/

insert into #result2
            select 
                    A.AgentCode,
                    ACD.IdAgentCollectionDetail as IdMoveHistory, 
                    --ACC.Name as Concept, 
                    'CP' as Concept, 
                    round(case when ACD.AmountToPay>0 then 1 else -1 end * ACD.AmountToPay,2) AmountToPay, 
                    round(ACD.ActualAmountToPay,2) ActualAmountToPay, 
                    round(ACD.LastAmountToPay,2) LastAmountToPay, 
                    --case when ACD.LastAmountToPay=0 
                    --    then 'Deferred Plan Started' +
                    --        case when isnull(ACD.Note ,'')='' then '' else ' - '+ACD.Note end
                    --    else ACD.Note 
                    --end
                    ACD.Note note,
                    username, 
                    ACD.DateofLastChange, 
                    case when ACD.LastAmountToPay=0 then 'Deferred Plan Started' else '' end IsCollectPlan, 
                    case when ACD.LastAmountToPay-ACD.ActualAmountToPay<0 then 'Debit' else 'Credit' end DebitOrCredit
	            from AgentCollectionDetail ACD 
                inner join 
	                AgentCollection AC on AC.IdAgentCollection = ACD.IdAgentCollection 
                inner join
	            AgentCollectionConcept ACC on ACC.IdAgentCollectionConcept = ACD.IdAgentCollectionConcept
                join agent a on a.idagent=ac.idagent
                join users u on u.iduser=ACD.enterbyiduser

            where ACD.DateofLastChange >=dbo.RemoveTimeFromDatetime(@StartDate) and ACD.DateofLastChange <dbo.RemoveTimeFromDatetime(@EndDate)
                and ACD.AmountToPay!=0
                and a.IdAgent=isnull(@IdAgent,a.idagent)

if (@IsExcel=1)
begin
    SELECT @PageCount = COUNT(1) FROM #result2
    select AGENTCODE,IDMOVEHISTORY, CONCEPT, AMOUNTTOPAY , ACTUALAMOUNTTOPAY,LASTAMOUNTTOPAY,NOTE,USERNAME,DATEOFLASTCHANGE,ISCOLLECTPLAN,DEBITORCREDIT from #result2      
    order by AgentCode,DateofLastChange 
end
else
begin

;WITH cte AS
(
SELECT  
  ROW_NUMBER() OVER(
    ORDER BY 
        CASE WHEN @columOrdering = 'AGENTCODE' THEN AGENTCODE END ,      
        CASE WHEN @columOrdering = 'IDMOVEHISTORY' THEN IDMOVEHISTORY END ,              
        CASE WHEN @columOrdering = 'CONCEPT' THEN CONCEPT END ,      
        CASE WHEN @columOrdering = 'AMOUNTTOPAY' THEN AMOUNTTOPAY END ,      
        CASE WHEN @columOrdering = 'ACTUALAMOUNTTOPAY' THEN ACTUALAMOUNTTOPAY END ,      
        CASE WHEN @columOrdering = 'LASTAMOUNTTOPAY' THEN LASTAMOUNTTOPAY END ,      
        CASE WHEN @columOrdering = 'NOTE' THEN NOTE END ,      
        CASE WHEN @columOrdering = 'USERNAME' THEN USERNAME END ,      
        CASE WHEN @columOrdering = 'DATEOFLASTCHANGE' THEN DATEOFLASTCHANGE END ,
        CASE WHEN @columOrdering = 'ISCOLLECTPLAN' THEN ISCOLLECTPLAN END ,
        CASE WHEN @columOrdering = 'DEBITORCREDIT' THEN DEBITORCREDIT END 
   )RowNumber,
    AGENTCODE,IDMOVEHISTORY, CONCEPT, AMOUNTTOPAY , ACTUALAMOUNTTOPAY,LASTAMOUNTTOPAY,NOTE,USERNAME,DATEOFLASTCHANGE,ISCOLLECTPLAN,DEBITORCREDIT
from 
    #result2
)
INSERT INTO #output
SELECT   AGENTCODE,IDMOVEHISTORY, CONCEPT, AMOUNTTOPAY , ACTUALAMOUNTTOPAY,LASTAMOUNTTOPAY,NOTE,USERNAME,DATEOFLASTCHANGE,ISCOLLECTPLAN,DEBITORCREDIT
FROM    cte
ORDER BY
CASE WHEN @order='DESC' THEN -RowNumber ELSE RowNumber END

SELECT @PageCount = COUNT(1) FROM #output

select AGENTCODE,IDMOVEHISTORY, CONCEPT, AMOUNTTOPAY , ACTUALAMOUNTTOPAY,LASTAMOUNTTOPAY,NOTE,USERNAME,DATEOFLASTCHANGE,ISCOLLECTPLAN,DEBITORCREDIT
FROM #output
WHERE Id BETWEEN @PageIndex + 1 AND @PageIndex + @PageSize

end
