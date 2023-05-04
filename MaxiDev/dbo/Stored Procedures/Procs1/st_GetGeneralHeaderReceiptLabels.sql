CREATE PROCEDURE st_GetGeneralHeaderReceiptLabels
--(
--	@IdUser		INT
--)
AS
BEGIN
	DECLARE @Label TABLE(LabelName VARCHAR(200), LabelValue VARCHAR(MAX))
	INSERT INTO @Label(LabelName, LabelValue)
	VALUES 
	('Header.Company.Name', 'MAXITRANSFERS, LLC'),
	('Header.Company.Address1', '222 Las Colinas Blvd. W. Ste. 2000,'),
	('Header.Company.Address2', 'Irving, TX 75039'),

	('Header.CustomerService.Label', 'CUSTOMER SERVICE:'),
	('Header.CustomerService.Phone', '(866) 216-2852'),
	('Header.CustomerService.Schedule1', '(Monday - Friday 9:00 -21:00)'),
	('Header.CustomerService.Schedule2', '(Saturdays - Sundays 9:00 - 19:00) (PST)'),

	('Header.Receipt', 'Receipt / Recibo'),
	('Header.Folio', 'Invoice / Folio:'),
	('Header.TypeOfService', 'Type of Service')


	--SELECT u.
	--FROM Users u WITH(NOLOCK)
	--	JOIN AgentUser au ON au.IdUser = u.IdUser
	--	JOIN Agent a ON a.IdAgent = au.IdAgent
	--WHERE u.IdUser = @IdUser


	SELECT * FROM @Label
END
