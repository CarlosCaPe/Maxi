CREATE procedure [Corp].[st_ReportOtherChargesCHV2]
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
            from 
                [AgentCommisionCollection] c
            join
                agent a on a.idagent=c.idagent
            join 
                users u on u.iduser=c.enterbyiduser
            join
                CommisionCollectionConcept cc on c.IdCommisionCollectionConcept =cc.IdCommisionCollectionConcept
            where                 
                dateofcollection>=@StartDate and dateofcollection<@EndDate
                and 
                a.IdAgent=isnull(@IdAgent,a.idagent)         
*/

create table #result3
(
    Id int IDENTITY (1,1),
    agentcode nvarchar(max),
    Commission money,
    dateofcollection datetime,
    username nvarchar(max),
    name nvarchar(max),
    note nvarchar(max)
)

create table #OUTPUT
(
    Id int IDENTITY (1,1),
    agentcode nvarchar(max),
    Commission money,
    dateofcollection datetime,
    username nvarchar(max),
    name nvarchar(max),
    note nvarchar(max)
)

/*
if (isnull(@PageCount,0)=0 and @IsExcel=0)
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
            insert into #result3
            select 
                agentcode,
                round(Commission,2) Commission,
                dateofcollection,
                username,
                cc.name CommisionCollectionConcept,
                note 
            from 
                [AgentCommisionCollection] c
            join
                agent a on a.idagent=c.idagent
            join 
                users u on u.iduser=c.enterbyiduser
            join
                CommisionCollectionConcept cc on c.IdCommisionCollectionConcept =cc.IdCommisionCollectionConcept
            where 
                --IdCommisionCollectionConcept=2 
                --and     
                dateofcollection>=@StartDate and dateofcollection<@EndDate
                and 
                a.IdAgent=isnull(@IdAgent,a.idagent)
            --order by A.AgentCode,dateofcollection
    end
end
*/

insert into #result3
            select 
                agentcode,
                round(Commission,2) Commission,
                dateofcollection,
                username,
                cc.name CommisionCollectionConcept,
                note 
            from 
                [AgentCommisionCollection] c with(nolock)
            join
                agent a with(nolock) on a.idagent=c.idagent
            join 
                users u with(nolock) on u.iduser=c.enterbyiduser
            join
                CommisionCollectionConcept cc with(nolock) on c.IdCommisionCollectionConcept =cc.IdCommisionCollectionConcept
            where 
                --IdCommisionCollectionConcept=2 
                --and     
                dateofcollection>=@StartDate and dateofcollection<@EndDate
                and 
                a.IdAgent=isnull(@IdAgent,a.idagent)

if (@IsExcel=1)
begin
select AGENTCODE,COMMISSION,DATEOFCOLLECTION,USERNAME,NAME,NOTE from #result3 
order by AgentCode,dateofcollection
end
else
begin

;WITH cte AS
(
SELECT  
  ROW_NUMBER() OVER(
    ORDER BY 
        CASE WHEN @columOrdering = 'AGENTCODE' THEN AGENTCODE END ,      
        CASE WHEN @columOrdering = 'COMMISSION' THEN COMMISSION END ,              
        CASE WHEN @columOrdering = 'DATEOFCOLLECTION' THEN DATEOFCOLLECTION END ,      
        CASE WHEN @columOrdering = 'USERNAME' THEN USERNAME END ,      
        CASE WHEN @columOrdering = 'NAME' THEN NAME END ,      
        CASE WHEN @columOrdering = 'NOTE' THEN NOTE END 
   )RowNumber,
    AGENTCODE,COMMISSION,DATEOFCOLLECTION,USERNAME,NAME,NOTE
from 
    #result3
)
INSERT INTO #output
SELECT   AGENTCODE,COMMISSION,DATEOFCOLLECTION,USERNAME,NAME,NOTE
FROM    cte with(nolock)
ORDER BY
CASE WHEN @order='DESC' THEN -RowNumber ELSE RowNumber END

SELECT @PageCount = COUNT(1) FROM #output

select AGENTCODE,COMMISSION,DATEOFCOLLECTION,USERNAME,NAME,NOTE
FROM #output
WHERE Id BETWEEN @PageIndex + 1 AND @PageIndex + @PageSize

end
