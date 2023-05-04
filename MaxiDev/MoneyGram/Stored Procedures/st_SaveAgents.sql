CREATE PROCEDURE MoneyGram.st_SaveAgents
(
	@CountryCode		VARCHAR(10),
	@StateProvinceCode	VARCHAR(10),
	@City				VARCHAR(200),
	@XMLSource			XML,
	@AgentId			VARCHAR(200)
)
AS
BEGIN

	DECLARE @NewAgent TABLE(IdAgent BIGINT, XMLStoreHours XML)

	;WITH XMLCatalog AS
    (
		SELECT
			t.c.value('AgentName[1]', 'varchar(200)') AgentName,
			t.c.value('Address[1]', 'varchar(200)') Address,
			t.c.value('City[1]', 'varchar(200)') City,
			t.c.value('State[1]', 'varchar(200)') State,
			t.c.value('ReceiveCapability[1]', 'BIT') ReceiveCapability,
			t.c.value('SendCapability[1]', 'BIT') SendCapability,
			t.c.value('AgentPhone[1]', 'varchar(200)') AgentPhone,
			CAST(t.c.query('StoreHours') AS XML) StoreHours
		FROM @XMLSource.nodes('root/AgentCatalog') t(c)
    )
    MERGE MoneyGram.Agent AS t
    USING XMLCatalog c ON 
		ISNULL(t.AgentName, '') = ISNULL(c.AgentName, '')
		AND ISNULL(t.Address, '') = ISNULL(c.Address, '')
		AND ISNULL(t.City, '') = ISNULL(c.City, '')
		AND ISNULL(t.State, '') = ISNULL(c.State, '')
		AND ISNULL(t.AgentPhone, '') = ISNULL(c.AgentPhone, '')
    WHEN MATCHED THEN
        UPDATE SET
            ReceiveCapability = c.ReceiveCapability,
			SendCapability = c.SendCapability,
			DateOfLastChange = GETDATE()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            AgentName,
            [Address],
            City, 
            [State],
			ReceiveCapability,
			SendCapability,
			AgentPhone,
			DateOfLastChange,
			CreationDate,
			Active
        )
        VALUES (
			c.AgentName,
			c.Address,
			c.City,
			c.State,
			c.ReceiveCapability,
			c.SendCapability,
			c.AgentPhone,
			NULL,
			GETDATE(),
			1
        )
	OUTPUT INSERTED.IdAgent, c.StoreHours INTO @NewAgent(IdAgent, XMLStoreHours);

	UPDATE MoneyGram.Agent SET
		Active = 0,
		DateOfLastChange = GETDATE()
	WHERE ISNULL(State, '') = ISNULL(@StateProvinceCode, '')
	AND ISNULL(City, '') = ISNULL(@City, '')
	AND NOT EXISTS (SELECT * FROM @NewAgent nc WHERE nc.IdAgent = Agent.IdAgent)

	;WITH XMLAgentStoreHours AS 
	(
		SELECT 
			na.IdAgent,
			t.c.value('DayOfWeek[1]', 'varchar(200)') [DayOfWeek],
			t.c.value('OpenTime[1]', 'TIME') OpenTime,
			t.c.value('CloseTime[1]', 'TIME') CloseTime,
			t.c.value('Closed[1]', 'BIT') Closed
		FROM @NewAgent na
		CROSS APPLY na.XMLStoreHours.nodes('/StoreHours/AgentStoreHour') t(c)
	)
	MERGE MoneyGram.AgentStoreHours AS t
	USING XMLAgentStoreHours c ON	
		c.DayOfWeek = t.DayOfWeek
		AND c.IdAgent = t.IdAgent
	WHEN MATCHED THEN
		UPDATE SET
			OpenTime = c.OpenTime,
			CloseTime = c.CloseTime,
			Closed  = c.Closed,
			DateOfLastChange = GETDATE()
	WHEN NOT MATCHED THEN
		INSERT (IdAgent, DayOfWeek, OpenTime, CloseTime, Closed, DateOfLastChange, CreationDate, Active)
		VALUES(c.IdAgent, c.DayOfWeek, c.OpenTime, c.CloseTime, c.Closed, NULL, GETDATE(), 1)
	WHEN NOT MATCHED BY SOURCE AND EXISTS(SELECT 1 FROM @NewAgent a WHERE a.IdAgent = t.IdAgent) THEN
		UPDATE SET
			Active = 0,
			DateOfLastChange = GETDATE();



END