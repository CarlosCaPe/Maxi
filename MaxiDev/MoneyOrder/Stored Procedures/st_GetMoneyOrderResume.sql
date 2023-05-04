
CREATE PROCEDURE [MoneyOrder].[st_GetMoneyOrderResume]
(
	@IdSaleRecord		INT
)
AS
/********************************************************************
<Author>adominguez</Author>
<app>MaxiCorp</app>
<Description>Get summary of MO for printing</Description>

<ChangeLog>
	<log Date="12/26/2022" Author="raarce">Se agrega el codigo de la agencia al domicilio</log>
	<log Date="11/18/2022" Author="jcsierra">Se agrega la direccion de la agencia</log>
</ChangeLog>
********************************************************************/
BEGIN

	DECLARE @IndexSplit		INT,
		@AgentAddress1	VARCHAR(2000),
		@AgentAddress2	VARCHAR(2000),
		@AgentAddress3	VARCHAR(2000),
		@AgentAddress4	VARCHAR(2000),
		@LimitLine		INT = 25

	SELECT
		@AgentAddress1 = a.AgentCode,
		@AgentAddress2 = a.AgentAddress,
		@AgentAddress3 = '',
		@AgentAddress4 = CONCAT(a.AgentCity, ' ', a.AgentState, ' ', a.AgentZipCode)
	FROM MoneyOrder.SaleRecord r WITH(NOLOCK)
		JOIN Agent a WITH(NOLOCK) ON a.IdAgent = r.IdAgent
	WHERE 
		r.IdSaleRecord = @IdSaleRecord


	IF LEN(@AgentAddress2) >= @LimitLine
	BEGIN
		SET @IndexSplit = @LimitLine - CHARINDEX(' ', REVERSE(SUBSTRING(@AgentAddress2, 0, @LimitLine)))

		SET @AgentAddress3 = SUBSTRING(@AgentAddress2, @IndexSplit + 1, LEN(@AgentAddress2))
		SET @AgentAddress2 = SUBSTRING(@AgentAddress2, 0, @IndexSplit)
	END


	SELECT 
		sr.IdSaleRecord,
		@AgentAddress1		CompanyAddress1,
		@AgentAddress2		CompanyAddress2,
		@AgentAddress3		CompanyAddress3,
		@AgentAddress4		CompanyAddress4,
		sr.IdCustomer		IdCustomer,
		sr.Payee			PayeeName,
		sr.Remitter			RemitterName,
		sr.SaleDate			IssuerDate,
		sr.SequenceNumber	[Sequence],
		sr.Amount			Amount
	FROM MoneyOrder.SaleRecord sr WITH(NOLOCK)
	WHERE
		sr.IdSaleRecord = @IdSaleRecord
END