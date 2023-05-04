CREATE PROCEDURE [dbo].[st_FindPayerConfigById]
(
	@IdPayer  INT
)
AS
BEGIN
  SELECT
	pc.IdPayerConfig,pc.IdGateway, pc.IdPaymentType, pc.IdCountryCurrency, pc.IdGenericStatus,
	pc.SpreadValue,pc.DateOfLastChange, pc.EnterByIdUser, pc.DepositHold, pc.RequireBranch, 
	pc.EnabledSchedule, pc.StartTime, pc.EndTime
	FROM PayerConfig pc
	WHERE pc.IdPayer=@IdPayer;
	
END