CREATE PROCEDURE [dbo].[st_UpdateCustomerSearch]
(
	@IdCustomer	INT
)
AS 
BEGIN
	SELECT
		c.IdCustomer,
		c.IdAgentCreatedBy,
		c.IdGenericStatus,
		SUBSTRING(dbo.fn_EspecialChrOFF(CONCAT(c.Name, ' ', c.FirstLastName, ' ', c.SecondLastName)), 1, 1500) FullNameRaw,
		CONCAT(dbo.PhoneticStandardize(c.Name, 1), '_', dbo.PhoneticStandardize(c.FirstLastName, 1), '_', dbo.PhoneticStandardize(c.SecondLastName, 1)) FullNameClean,
		CONCAT(dbo.DoubleMetaPhone(dbo.PhoneticStandardize(c.Name, 1)), '_', dbo.DoubleMetaPhone(dbo.PhoneticStandardize(c.FirstLastName, 1)), '_', dbo.DoubleMetaPhone(dbo.PhoneticStandardize(c.SecondLastName, 1))) MetaPhoneSplit,
		dbo.PhoneticStandardize(c.PhoneNumber, 1) PhoneNumber,
		dbo.PhoneticStandardize(c.CelullarNumber, 1) CelullarNumber
	INTO #CurrentCustomer
	FROM Customer c WITH (NOLOCK)
	WHERE c.IdCustomer = @IdCustomer

	IF NOT EXISTS(SELECT 1 FROM Customer c WITH(NOLOCK) WHERE c.IdCustomer = @IdCustomer)
		DELETE FROM CustomerSearch WHERE IdCustomer = @IdCustomer
	ELSE
	BEGIN
		IF EXISTS (SELECT 1 FROM CustomerSearch cs WITH(NOLOCK) WHERE cs.IdCustomer = @IdCustomer)
			UPDATE cs SET
				cs.IdAgent = cc.IdAgentCreatedBy,
				cs.IdStatus = cc.IdGenericStatus,
				cs.FullNameRaw = cc.FullNameRaw,
				cs.FullNameClean = cc.FullNameClean ,
				cs.MetaPhoneSplit = cc.MetaPhoneSplit,
				cs.PhoneNumber = cc.PhoneNumber,
				cs.CelullarNumber = cc.CelullarNumber
			FROM CustomerSearch cs
				JOIN #CurrentCustomer cc ON cc.IdCustomer = cs.IdCustomer
		ELSE
			INSERT INTO CustomerSearch
			SELECT
				cc.IdCustomer,
				cc.IdAgentCreatedBy,
				cc.IdGenericStatus,
				cc.FullNameRaw,
				cc.FullNameClean,
				cc.MetaPhoneSplit,
				cc.PhoneNumber,
				cc.CelullarNumber
			FROM #CurrentCustomer cc
	END
END
