/********************************************************************
<Author>jresendiz</Author>
<app>Corporate </app>
<Description></Description>

<ChangeLog>
<log Date="26/12/2018" Author="jresendiz"> Creado </log>
</ChangeLog>

*********************************************************************/
CREATE PROCEDURE [dbo].[st_GetBillAccount] 
	@IdBillAccounts int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT [IdBillAccounts]
      ,[AccountNumber]
      ,[IdProductsByProvider]
      ,[IdCustomer]
      ,[BillerDescription]
      ,[LastChanges_LastUserChange]
      ,[LastChanges_LastDateChange]
      ,[LastChanges_LastIpChange]
      ,[LastChanges_LastNoteChange]
      ,[AltAccountNumber]
      ,[CustomField1]
      ,[CustomField2]
      ,[AltAccountNumberLabel]
      ,[CustomField1Label]
      ,[CustomField2Label]
      ,[OnBehalf_LastName]
      ,[OnBehalf_MiddleName]
      ,[OnBehalf_FirstName]
      ,[OnBehalf_Occupation]
      ,[OnBehalf_Address]
      ,[OnBehalf_City]
      ,[OnBehalf_State]
      ,[OnBehalf_Zip]
      ,[OnBehalf_Telephone]
      ,[OnBehalf_IdType]
      ,[OnBehalf_IdIssuer]
      ,[OnBehalf_IdNumber]
      ,[OnBehalf_Ssn]
	FROM [dbo].[BillAccounts] WITH(NOLOCK)
	WHERE IdBillAccounts = @IdBillAccounts

END

