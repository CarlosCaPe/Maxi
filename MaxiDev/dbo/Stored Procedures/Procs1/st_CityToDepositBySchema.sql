CREATE Procedure [dbo].[st_CityToDepositBySchema]
(
@IdAgentSchema int,
@IdPayer int,
@IdState INT

)
AS
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="20/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;


declare @IdPaymentType int
set @IdPaymentType =2 --DEPOSIT
Set nocount on

Select 
	Distinct F.CityName, F.IdCity 
	from  AgentSchema A with(nolock)
		JOIN AgentSchemaDetail B with(nolock) on (A.IdAgentSchema=B.IdAgentSchema) 
		JOIN PayerConfig C with(nolock) on (B.IdPayerConfig=C.IdPayerConfig AND A.IdCountryCurrency =C.IdCountryCurrency )
		JOIN Payer D with(nolock) on (C.IdPayer=D.IdPayer)
		JOIN Branch E with(nolock) on (E.IdPayer=D.IdPayer)
		JOIN City F with(nolock) on (F.IdCity=E.IdCity)
Where B.IdAgentSchema=@IdAgentSchema 
	AND D.IdPayer =@IdPayer
	AND C.IdGenericStatus=1
	AND F.IdState=@IdState
	AND E.IdGenericStatus=1
	AND C.IdPaymentType=@IdPaymentType    
Order by F.CityName
