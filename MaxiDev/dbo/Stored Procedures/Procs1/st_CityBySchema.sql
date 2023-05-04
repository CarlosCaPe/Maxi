CREATE Procedure [dbo].[st_CityBySchema]
(
	@IdAgentSchema int,
	@IdState INT,
	@IdPaymentType int
)
AS

Select Distinct F.CityName, F.IdCity from  AgentSchema A (nolock)
JOIN AgentSchemaDetail B (nolock) on (A.IdAgentSchema=B.IdAgentSchema) 
JOIN PayerConfig C (nolock) on (B.IdPayerConfig=C.IdPayerConfig AND A.IdCountryCurrency =C.IdCountryCurrency )
JOIN Payer D (nolock) on (C.IdPayer=D.IdPayer) 
JOIN Branch E (nolock) on (E.IdPayer=D.IdPayer)
JOIN City F (nolock) on (F.IdCity=E.IdCity)
Where B.IdAgentSchema=@IdAgentSchema 
AND C.IdGenericStatus=1
AND F.IdState=@IdState
AND E.IdGenericStatus=1
AND D.IdGenericStatus =1
and dbo.fnPaymentTypeComparison(@IdPaymentType,C.IdPaymentType)=1
Order by F.CityName


