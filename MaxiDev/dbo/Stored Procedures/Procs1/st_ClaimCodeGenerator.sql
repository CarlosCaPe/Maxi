CREATE Procedure [dbo].[st_ClaimCodeGenerator]   
(  
@IdGateway int,  
@PayerCode nvarchar(max),  
@ClaimCode nvarchar(max) Output  
)  
AS  
Set nocount on  
Set @ClaimCode='Prueba01'
If @IdGateway=4
	Begin
		Set @ClaimCode='Prueba01'
		Return
	End


Create Table #Result  
(  
Result nvarchar(max)  
)  
  
--Insert into #Result (Result)  
--EXEC ST_TNC_CLAIM_CODE_GEN @PayerCode  
--Select @ClaimCode = ltrim(rtrim(Result)) From #Result 

If @ClaimCode IS NULL
	Set @ClaimCode='Prueba'
