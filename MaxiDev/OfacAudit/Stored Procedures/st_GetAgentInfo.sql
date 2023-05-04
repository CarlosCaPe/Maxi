CREATE procedure [OfacAudit].[st_GetAgentInfo]
(
    @IdAgent int
)
as

select AgentName,isnull(DoingBusinessAs,'') DBA, OpenDate,AgentAddress Address, isnull(CountyName,'') County, AgentZipCode ZipCode, AgentPhone Phone, AgentFax Fax, isnull(AgentState,'') AgentState,isnull(AgentCity,'') AgentCity from agent a left join county c on a.idcounty=c.idcounty where IdAgent=@IdAgent

select r.IdCountyClass, c.CountyClassName from RelationCountyCountyClass r 
join CountyClass c on r.IdCountyClass = c.IdCountyClass
where idcounty in
(
    select idcounty from agent a where a.IdAgent=@IdAgent
)