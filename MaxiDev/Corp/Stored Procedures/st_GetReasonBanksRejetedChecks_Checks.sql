CREATE PROCEDURE [Corp].[st_GetReasonBanksRejetedChecks_Checks]
	@idBank int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    select  
  IdReason 
  , MaxiReason
  , BankReason 
 from 
   CheckConfig.ReasonBanksRejetedChecks with (nolock)
 where 
   idBank= @idBank
END

