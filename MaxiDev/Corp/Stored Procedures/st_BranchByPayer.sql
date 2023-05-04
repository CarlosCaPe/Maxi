CREATE PROCEDURE [Corp].[st_BranchByPayer]  
(  
@IdPayer INT,  
@IdGateway INT  
)  
AS  
Set nocount on  
Select E.BranchName  
 ,E.IdBranch   
 ,Ci.CityName  
 ,S.StateName  
 ,Cy.CountryName
 ,E.Address  
 ,E.zipcode  
 ,E.Phone  
 ,E.Fax  
 ,isnull(GB.GatewayBranchCode  ,'') GatewayBranchCode 
 from Branch E WITH (NOLOCK)
  JOIN City Ci WITH (NOLOCK) on Ci.IdCity =E.IdCity  
 JOIN State S WITH (NOLOCK) on S.IdState =Ci.IdState  
 join Country Cy WITH (NOLOCK) on Cy.IdCountry = S.IdCountry
 left Join GatewayBranch GB WITH (NOLOCK) on GB.IdBranch = E.IdBranch and GB.IdGateway =  @IdGateway   
Where E.IdGenericStatus=1 AND E.IdPayer=@IdPayer     
Order by E.BranchName

