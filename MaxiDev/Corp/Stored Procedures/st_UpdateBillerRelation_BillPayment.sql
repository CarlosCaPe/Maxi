CREATE PROCEDURE [Corp].[st_UpdateBillerRelation_BillPayment] @IdBiller INT --200620191732_azavala
, @IdBillerAggregator INT
, @Relationship VARCHAR(250)
, @IdUser INT
, @IdAggregator INT
, @ChoiseData NVARCHAR(150) --200620191732_azavala
, @HasError INT OUT
, @Message NVARCHAR(MAX) OUT
AS

/********************************************************************
<Author>Amoreno</Author>
<app>MaxiCorp</app>
<Description>Actualizar el nombre del Biller</Description>

<ChangeLog>

<log Date="20/06/2018" Author="amoreno">Creation</log>
<log Date="20/06/2019" Author="azavala">Add Parameters as IdBiller and ChoiseData to identify the correct biller for the new Fiserv's Process:: Ref: 200620191732_azavala</log>
</ChangeLog>

*********************************************************************/
BEGIN TRY
	--insert into ErrorLogForStoreProcedure (StoreProcedure, ErrorDate, ErrorMessage) values ('Corp.st_UpdateBillerRelation_BillPayment', GETDATE(), 'IdBiller: ' + Convert(varchar(max), @IdBiller) + '; IdBillerAggregator: ' + Convert(varchar(max), @idBillerAggregator) + '; ChoiseData: ' + @ChoiseData)

	SET @HasError = 0
	SET @Message = ''

	DECLARE @RelationshipSelect VARCHAR(100)


	IF EXISTS (SELECT
				1
			FROM BillPayment.Billers WITH (NOLOCK)
			WHERE IdAggregator = @IdAggregator
			AND IdBillerAggregator = @IdBillerAggregator
			AND IdBiller = @IdBiller) --200620191732_azavala
	BEGIN
		UPDATE BillPayment.Billers
		SET Relationship = @Relationship
		WHERE IdAggregator = @IdAggregator
		AND IdBillerAggregator = @IdBillerAggregator
		AND IdBiller = @IdBiller --200620191732_azavala

		INSERT INTO BillPayment.LogForBillers (IdBiller
		, IdUser
		, MovementType
		, DateLastChangue
		, Description)
			VALUES (@IdBiller, @IdUser, 'Update Info', GETDATE(), 'Relationship change' + ' ' + @Relationship)
		SELECT
			@HasError = 0
		   ,@Message = 'Biller Relation has been successfully saved';
	END
	ELSE
	BEGIN
		SET @HasError = 1
		SET @Message = 'Error Update Relationship'
	END


END TRY
BEGIN CATCH
	SET @HasError = 1
	SET @Message = 'Error'
	INSERT INTO ErrorLogForStoreProcedure (StoreProcedure, ErrorDate, ErrorMessage)
		VALUES ('Corp.st_UpdateBillerRelation_BillPayment', GETDATE(), ERROR_MESSAGE())
END CATCH
