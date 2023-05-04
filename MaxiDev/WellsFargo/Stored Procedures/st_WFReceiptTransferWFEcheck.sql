CREATE PROCEDURE [WellsFargo].[st_WFReceiptTransferWFEcheck]
(
@IdTransferWFEcheck int
)
AS
BEGIN
	SET NOCOUNT ON;
   
declare @CorporationPhone varchar(50)      
set @CorporationPhone = dbo.GetGlobalAttributeByName('CorporationPhone');     

declare @CorporationName varchar(50)      
set @CorporationName = dbo.GetGlobalAttributeByName('CorporationName');    
	   
	select 
    	t.Folio,
        TransID,
        Amount,
        t.DateOfCreation,
        /*AccountNumberData,*/
		[dbo].[fnDecryptData](AccountNumberData) AccountNumber,
        Reference, 
        ApplyDate,
        a.agentcode,
        a.AgentName,
        a.AgentAddress,        
        a.AgentPhone,
        ISNULL(A.AgentCity,'')+ ' '+ ISNULL(A.AgentState,'') + ' '+ 
			REPLACE(STR(isnull(A.AgentZipcode,0), 5), SPACE(1), '0') AS  AgentLocation,
        @CorporationPhone CorporationPhone,      
        @CorporationName CorporationName,
        UserLogin 
	from [WellsFargo].[TransferWFEcheck] t
    join agent a on t.idagent=a.idagent
    join users u on t.EnterByIDUser=u.iduser
	where IdTransferWFEcheck = @IdTransferWFEcheck 
END
