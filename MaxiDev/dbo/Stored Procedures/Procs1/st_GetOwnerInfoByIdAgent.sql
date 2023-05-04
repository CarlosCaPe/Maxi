CREATE procedure [dbo].[st_GetOwnerInfoByIdAgent]
(
	@IdAgent int
)
as
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="20/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

/****** Script for SelectTopNRows command from SSMS  ******/
SELECT 
	   o.[IdOwner]
      ,[Name]
      ,[LastName]     
      ,[Address]
      ,[City]
      ,[State]
      ,[Zipcode]
      ,[Phone]
      ,[Cel]
      ,[Email]
	  ,a.AccountNumber
	  ,a.RoutingNumber 
      ,o.idcounty    
      ,isnull(Countyname,'') Countyname      
  FROM dbo.[Owner] o with(nolock)
  inner join Agent a with(nolock) on o.IdOwner = a.IdOwner
  left join county c with(nolock) on o.idcounty=c.idcounty
  where idAgent = @IdAgent

select r.idcountyclass,countyclassname from [RelationCountyCountyClass] r  with(nolock) left join countyclass c  with(nolock) on r.idcountyclass=c.idcountyclass where idcounty in (select o.idcounty from [owner] o with(nolock) inner join Agent a with(nolock) on o.IdOwner = a.IdOwner where idAgent = @IdAgent) order by countyclassname