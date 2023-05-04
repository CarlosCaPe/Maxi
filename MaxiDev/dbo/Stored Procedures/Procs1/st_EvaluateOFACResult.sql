/********************************************************************
<Author>jsierra</Author>
<app>MaxiAgent</app>
<Description></Description>

<ChangeLog>
<log Date="15/08/2022" Author="jsierra"> Se remplaza las instrucciones WITH por tablas temporales </log>
</ChangeLog>
********************************************************************/
CREATE PROCEDURE [dbo].[st_EvaluateOFACResult] (
    @XMLResult      XML,
    @Score          FLOAT   OUT,
    @Message        VARCHAR(300) OUT,
    @HasMatch       BIT OUT,
    @CanDiscard     BIT OUT,
    @Matches        XML OUT
) 
AS 
BEGIN

    DECLARE @Method                 VARCHAR(200),
            @GeneralStatus          VARCHAR(200),
            @PercentOFACFullMatch   FLOAT

	CREATE TABLE #MatchEntities
	(
		NameComplete   VARCHAR(500),
		Remarks        VARCHAR(500),
		Type           VARCHAR(500),
		Address        VARCHAR(500),
		CityName       VARCHAR(500),
		Country        VARCHAR(500),
		AddRemarks     VARCHAR(500),
		Score          FLOAT,
		[Message]      VARCHAR(500),
		[Status]       VARCHAR(500),
		AkaList        XML
	)

	CREATE TABLE #LogMatch
	(
		SDN_NAME		VARCHAR(500),
		SDN_REMARKS     VARCHAR(500),
		ALT_TYPE        VARCHAR(500),
		ALT_NAME		VARCHAR(500),
		ALT_REMARKS		VARCHAR(500),
		ADD_ADDRESS     VARCHAR(500),
		ADD_CITY_NAME   VARCHAR(500),
		ADD_COUNTRY     VARCHAR(500),
		ADD_REMARKS     VARCHAR(500),
		Percent_Match   FLOAT,
		[MESSAGE]		VARCHAR(500),
		[STATUS]		VARCHAR(500),
		FULL_Match		BIT,
		Method			VARCHAR(500),
	)

    SELECT
        @HasMatch = t.c.value('HasMatch[1]', 'BIT'),
        @GeneralStatus = t.c.value('GeneralStatus[1]', 'VARCHAR(20)'),
        @Method = CONCAT(t.c.value('Filter[1]', 'VARCHAR(20)'), '/', t.c.value('DiscardResolver[1]', 'VARCHAR(20)')),
        @Message = t.c.value('GeneralMessage[1]', 'VARCHAR(300)')
    FROM @XMLResult.nodes('/MatchResult') t(c)

    SET @CanDiscard = CASE 
        WHEN @HasMatch = 0 THEN 1
        WHEN @GeneralStatus = 'DiscardMatch' THEN 1 
        ELSE 0 
    END

    SET @PercentOFACFullMatch = [dbo].[GetGlobalAttributeByName]('PercentOfacMatchBit')

	INSERT INTO #MatchEntities(NameComplete, Remarks, Type, Address, CityName, Country, AddRemarks, Score, [Message], [Status], AkaList)
	SELECT
        t.c.value('NameComplete[1]', 'VARCHAR(500)') NameComplete,
        t.c.value('Remarks[1]', 'VARCHAR(500)') Remarks,
        t.c.value('Type[1]', 'VARCHAR(500)') Type,
        t.c.value('Address[1]', 'VARCHAR(500)') Address,    
        t.c.value('CityName[1]', 'VARCHAR(500)') CityName,
        t.c.value('Country[1]', 'VARCHAR(500)') Country,
        t.c.value('AddRemarks[1]', 'VARCHAR(500)') AddRemarks,
        t.c.value('Score[1]', 'DECIMAL(6, 2)') Score,
        t.c.value('Message[1]', 'VARCHAR(500)') [Message],
        t.c.value('Status[1]', 'VARCHAR(500)') [Status],
        CAST(t.c.query('./AkaList') AS XML) AkaList
    FROM @XMLResult.nodes('/MatchResult/MatchEntities/MatchEntity') t(c)

	INSERT INTO #LogMatch(SDN_NAME, SDN_REMARKS, ALT_TYPE, ALT_NAME, ALT_REMARKS, ADD_ADDRESS, ADD_CITY_NAME, ADD_COUNTRY, ADD_REMARKS, Percent_Match, [MESSAGE], [STATUS], FULL_Match, Method)
	SELECT
        me.NameComplete SDN_NAME,
        me.Remarks SDN_REMARKS,
		me.Type ALT_TYPE,
		me.NameComplete ALT_NAME,
		me.Remarks ALT_REMARKS,
		me.Address ADD_ADDRESS,    
		me.CityName ADD_CITY_NAME,
		me.Country ADD_COUNTRY,
		me.AddRemarks ADD_REMARKS,
		me.Score Percent_Match,
		me.Message [MESSAGE],
		me.Status [STATUS],
		CASE WHEN me.Score >= @PercentOFACFullMatch THEN 1 ELSE 0 END FULL_Match,
        @Method Method
    FROM #MatchEntities me
	UNION
    SELECT
        me.NameComplete SDN_NAME,
        me.Remarks SDN_REMARKS,
        t.c.value('Type[1]', 'VARCHAR(500)') ALT_TYPE,
        t.c.value('NameComplete[1]', 'VARCHAR(500)') ALT_NAME,
        t.c.value('Remarks[1]', 'VARCHAR(500)') ALT_REMARKS,
        t.c.value('Address[1]', 'VARCHAR(500)') ADD_ADDRESS,    
        t.c.value('CityName[1]', 'VARCHAR(500)') ADD_CITY_NAME,
        t.c.value('Country[1]', 'VARCHAR(500)') ADD_COUNTRY,
        t.c.value('AddRemarks[1]', 'VARCHAR(500)') ADD_REMARKS,
        t.c.value('Score[1]', 'DECIMAL(6, 2)') Percent_Match,
        ISNULL(t.c.value('Message[1]', 'VARCHAR(500)'), '') [MESSAGE],
        t.c.value('Status[1]', 'VARCHAR(500)') [STATUS],
        CASE WHEN t.c.value('Score[1]', 'FLOAT') >= @PercentOFACFullMatch THEN 1 ELSE 0 END FULL_Match,
        @Method Method
    FROM #MatchEntities me
    CROSS APPLY me.AkaList.nodes('/AkaList/MatchEntity') t(c)

	SELECT 
        @Matches=(SELECT * FROM #LogMatch FOR XML RAW, ROOT('OFACInfo')),
        @Score = ISNULL((SELECT MAX(Percent_Match) FROM #LogMatch), 0)

	DROP TABLE #MatchEntities
	DROP TABLE #LogMatch
END