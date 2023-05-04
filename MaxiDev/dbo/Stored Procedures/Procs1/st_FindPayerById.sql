CREATE PROCEDURE [dbo].[st_FindPayerById]
(
	@IdPayer  INT
)
AS
BEGIN
  SELECT
	cc.IdPayer, cc.PayerName, cc.PayerCode, cc.IdGenericStatus,cc.DateOfLastChange, cc.EnterByIdUser
	FROM payer cc
	WHERE cc.IdPayer=@IdPayer;
	
END