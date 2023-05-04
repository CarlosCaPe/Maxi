/********************************************************************
<app>Hermes</app>
<Description></Description>

<ChangeLog>
    <log Date="2022-04-20" Author="jcsierra">Create SP</log>
</ChangeLog>
*********************************************************************/
CREATE Procedure [dbo].[st_GetBranchesByState]
(
    @IdAgentSchema  INT,
    @IdState        INT,
    @IdPayer        INT,
    @IdPaymentType  INT,
    @IdGateway      INT
)
AS
BEGIN

    SELECT 
        b.BranchName,
        b.IdBranch ,
        b.IdPayer,
        b.IdCity,
        st.IdState,
        ct.CityName,
        st.StateName,
        b.[Address],
        b.zipcode,
        b.Phone,
        b.Fax,
        b.IdGenericStatus,
        gb.GatewayBranchCode
    FROM  AgentSchema s with(nolock)
        JOIN AgentSchemaDetail asd with(nolock) on (s.IdAgentSchema=asd.IdAgentSchema) 
        JOIN PayerConfig pc with(nolock) on (asd.IdPayerConfig=pc.IdPayerConfig) AND s.IdCountryCurrency =pc.IdCountryCurrency  
        JOIN Payer p with(nolock) on (pc.IdPayer=p.IdPayer)
        JOIN Branch b with(nolock) on (b.IdPayer=p.IdPayer)
        LEFT Join GatewayBranch gb with(nolock) on gb.IdBranch = b.IdBranch and gb.IdGateway =  @IdGateway	
        JOIN City ct with(nolock) on ct.IdCity =b.IdCity
        JOIN [State] st with(nolock) on st.IdState =ct.IdState
    Where asd.IdAgentSchema=@IdAgentSchema 
        AND pc.IdGenericStatus=1 
        AND b.IdGenericStatus=1 
        AND p.IdGenericStatus=1
        AND st.IdState = @IdState	
        AND pc.IdPaymentType=@IdPaymentType
        AND p.IdPayer=@IdPayer   
    Order by b.BranchName

END