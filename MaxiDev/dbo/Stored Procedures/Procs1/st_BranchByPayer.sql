CREATE PROCEDURE [dbo].[st_BranchByPayer]  
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
 from Branch E 
  JOIN City Ci on Ci.IdCity =E.IdCity  
 JOIN State S on S.IdState =Ci.IdState  
 join Country Cy on Cy.IdCountry = S.IdCountry
 left Join GatewayBranch GB on GB.IdBranch = E.IdBranch and GB.IdGateway =  @IdGateway   
Where E.IdGenericStatus=1 AND E.IdPayer=@IdPayer     
Order by E.BranchName
