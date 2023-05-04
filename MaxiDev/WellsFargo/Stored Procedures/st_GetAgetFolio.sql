create procedure [WellsFargo].st_GetAgetFolio
(
    @IdAgent int,
    @Folio int out
)
as
if not exists (Select top 1 1 from [WellsFargo].[WFAgentFolio] where IdAgent=@IdAgent)
begin
    insert into [WellsFargo].[WFAgentFolio]
    (IdAgent,Folio)
    values
    (@IdAgent,0)
end

update [WellsFargo].[WFAgentFolio] set Folio=folio+1,@Folio=folio+1 where idagent=@IdAgent