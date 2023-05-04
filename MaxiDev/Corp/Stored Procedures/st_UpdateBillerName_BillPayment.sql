CREATE PROCEDURE [Corp].[st_UpdateBillerName_BillPayment] @IdBiller INT
, @Name VARCHAR(250)
, @IdUser INT
, @IdAggregator INT
, @HasError INT OUT
, @Message NVARCHAR(MAX) OUT
AS

/********************************************************************
<Author>Amoreno</Author>
<app>MaxiCorp</app>
<Description>Actualizar el nombre del Biller</Description>

<ChangeLog>

<log Date="20/06/2018" Author="amoreno">Creation</log>
</ChangeLog>
*Example*





declare
    @HasError int 
   , @Message nvarchar(max)


execute Corp.st_UpdateBillerName_BillPayment 1, 'TXU ENERGY ', 9012,1, @HasError  out, @Message  out

   
select * from BillPayment.Billers where IdBiller=1
select * from   BillPayment.LogForBillers where IdBiller=1	

*********************************************************************/
BEGIN TRY
	SET @HasError = 0
	SET @Message = ''


	-- if (@IdAggregator<>2)
	--  begin 
	IF NOT EXISTS (SELECT
				1
			FROM BillPayment.Billers WITH (NOLOCK)
			WHERE IdAggregator = @IdAggregator
			AND Name = @Name
			AND IdBiller <> @IdBiller)
	BEGIN

		UPDATE BillPayment.Billers
		SET Name = @Name
		WHERE IdBiller = @IdBiller
		AND IdAggregator = @IdAggregator

		INSERT INTO BillPayment.LogForBillers (IdBiller
		, IdUser
		, MovementType
		, DateLastChangue
		, Description)
			VALUES (@IdBiller, @IdUser, 'Update Info', GETDATE(), 'Name change' + ' ' + @Name)
		SELECT
			@HasError = 0
		   ,@Message = 'Biller Name has been successfully saved';
	END
	ELSE
	BEGIN
		SET @HasError = 1
		SET @Message = 'Name duplicate for the  Aggregator'
	END
-- end  

END TRY
BEGIN CATCH
	SET @HasError = 1
	SET @Message = 'Error'
	INSERT INTO ErrorLogForStoreProcedure (StoreProcedure, ErrorDate, ErrorMessage)
		VALUES ('Corp.st_UpdateBillerName_BillPayment', GETDATE(), ERROR_MESSAGE())
END CATCH
