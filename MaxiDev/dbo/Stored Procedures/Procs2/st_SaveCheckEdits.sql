
/********************************************************************
<Author>TSI</Author>
<app>Agent</app>
<Description>This SP analyze original vs captured data to register info about whath fields were modified </Description>

<ChangeLog>
<log Date="29/04/2021" Author="jgv"> Creación de sp </log>
<log Date="08/07/2021" Author="jgv"> valida monto configurado para hold </log>
</ChangeLog>
*********************************************************************/

CREATE PROCEDURE [dbo].[st_SaveCheckEdits](
	@IdCheck INT, 

	@OriRouting VARCHAR(MAX),
	@OriRoutingScore INT, 
	@Routing VARCHAR(MAX),

	@OriAccount VARCHAR(MAX),
	@OriAccountScore INT, 
	@Account VARCHAR(MAX),

	@OriCheckNum VARCHAR(MAX), 
	@OriCheckNumScore INT, 
	@CheckNum VARCHAR(MAX), 

	@OriDateOfIssue DATETIME,
	@OriDateOfIssueScore INT,
	@DateOfIssue DATETIME,

	@OriAmount MONEY,
	@OriAmountScore INT,
	@Amount MONEY,

	@IsEdited BIT OUTPUT
)
AS

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY

	SET @IsEdited = 0;

	--DECLARE @MinAmountForHold MONEY;
	DECLARE @MaxScore SMALLINT;
	DECLARE @EditLevel SMALLINT;

	SET @MaxScore = 80;
	
	
	--------------------------------------			
	------ Validate Routing Edited ------
	SET @EditLevel = 0;
	IF @Routing != @OriRouting
	BEGIN
		SELECT @MaxScore= ISNULL(TRY_CAST(Value AS SMALLINT),0) FROM dbo.GlobalAttributes WHERE [Name]='CheckEdit_RoutingScore';
		SET @EditLevel = 1;
		IF @OriRoutingScore >= @MaxScore SET @EditLevel = 2;
		SET @IsEdited = 1;
	END;

	IF @EditLevel > 0
	INSERT INTO dbo.CheckEdits
			( IdCheck ,
				EditName ,
				OriValue ,
				OriScore ,
				Value ,
				EditLevel
			)
	VALUES  ( @IdCheck , -- IdCheck - int
				'Routing' , -- EditName - varchar(50)
				@OriRouting , -- OriValue - varchar(100)
				@OriRoutingScore , -- OriScore - int
				@Routing , -- Value - varchar(100)
				@EditLevel  -- EditLevel - smallint
			);


	--------------------------------------
	------ Validate Account Edited ------
	SET @EditLevel = 0;
	IF @Account != @OriAccount
	BEGIN
		SELECT @MaxScore= ISNULL(TRY_CAST(Value AS SMALLINT),0) FROM dbo.GlobalAttributes WHERE [Name]='CheckEdit_AccountScore';
		SET @EditLevel = 1;
		IF @OriAccountScore >= @MaxScore SET @EditLevel = 2;
		SET @IsEdited = 1;
	END;

	IF @EditLevel > 0
	INSERT INTO dbo.CheckEdits
			( IdCheck ,
				EditName ,
				OriValue ,
				OriScore ,
				Value ,
				EditLevel
			)
	VALUES  ( @IdCheck , -- IdCheck - int
				'Account' , -- EditName - varchar(50)
				@OriAccount , -- OriValue - varchar(100)
				@OriAccountScore , -- OriScore - int
				@Account , -- Value - varchar(100)
				@EditLevel  -- EditLevel - smallint
			);


	--------------------------------------
	------ Validate CheckNum Edited ------
	SET @EditLevel = 0;
	IF @CheckNum != @OriCheckNum
	BEGIN
		SELECT @MaxScore= ISNULL(TRY_CAST(Value AS SMALLINT),0) FROM dbo.GlobalAttributes WHERE [Name]='CheckEdit_CheckNumScore';
		SET @EditLevel = 1;
		IF @OriCheckNumScore >= @MaxScore SET @EditLevel = 2;
		SET @IsEdited = 1;
	END;

	IF @EditLevel > 0
	INSERT INTO dbo.CheckEdits
			( IdCheck ,
				EditName ,
				OriValue ,
				OriScore ,
				Value ,
				EditLevel
			)
	VALUES  ( @IdCheck , -- IdCheck - int
				'CheckNum' , -- EditName - varchar(50)
				@OriCheckNum , -- OriValue - varchar(100)
				@OriCheckNumScore , -- OriScore - int
				@CheckNum , -- Value - varchar(100)
				@EditLevel  -- EditLevel - smallint
			);


	--------------------------------------
	------ Validate Amount Edited ------
	SET @EditLevel = 0;
	IF @Amount != @OriAmount
	BEGIN
		SELECT @MaxScore= ISNULL(TRY_CAST(Value AS SMALLINT),0) FROM dbo.GlobalAttributes WHERE [Name]='CheckEdit_AmountScore';
		SET @EditLevel = 1;
		IF @OriAmountScore >= @MaxScore SET @EditLevel = 2;
		SET @IsEdited = 1;
	END;

	IF @EditLevel = 0 --score minimo para hold
	BEGIN
		SELECT @MaxScore= ISNULL(TRY_CAST(Value AS SMALLINT),0) FROM dbo.GlobalAttributes WHERE [Name]='AmountScore_ForHold';
		IF @MaxScore>0 AND @OriAccountScore<=@MaxScore
		BEGIN
			SET @EditLevel = 1; --ver si se usa un 3 para indicar que no es edicion sino que es regla de score
			SET @IsEdited  = 1;
		END;
	END;

	IF @EditLevel > 0
	INSERT INTO dbo.CheckEdits
			( IdCheck ,
				EditName ,
				OriValue ,
				OriScore ,
				Value ,
				EditLevel
			)
	VALUES  ( @IdCheck , -- IdCheck - int
				'Amount' , -- EditName - varchar(50)
				@OriAmount , -- OriValue - varchar(100)
				@OriAmountScore , -- OriScore - int
				@Amount , -- Value - varchar(100)
				@EditLevel  -- EditLevel - smallint
			);



	--------------------------------------
	------ Validate check Date Edited ------
	/* se quita la revision por fecha hasta nuevo aviso  19-05-2021 JGV-JCG

	IF TRY_CAST(@DateOfIssue AS DATE)    = '1900-01-01' SET @DateOfIssue=NULL;
	IF TRY_CAST(@OriDateOfIssue AS DATE) = '1900-01-01' SET @OriDateOfIssue=NULL;

	SET @EditLevel = 0;
	DECLARE @SFecV VARCHAR(50) = ISNULL(CONVERT(VARCHAR(50), TRY_CAST(@DateOfIssue AS DATE), 126), '');
	DECLARE @SFecO VARCHAR(50) = ISNULL(CONVERT(VARCHAR(50), TRY_CAST(@OriDateOfIssue AS DATE), 126), '');

	IF @SFecV != @SFecO
	BEGIN
		SELECT @MaxScore= ISNULL(TRY_CAST(Value AS SMALLINT),0) FROM dbo.GlobalAttributes WHERE [Name]='CheckEdit_DateOfIssueScore';
		SET @EditLevel = 1;
		IF @OriDateOfIssueScore >= @MaxScore SET @EditLevel = 2;
		SET @IsEdited = 1;
	END;

	IF @EditLevel > 0
	INSERT INTO dbo.CheckEdits
			( IdCheck ,
				EditName ,
				OriValue ,
				OriScore ,
				Value ,
				EditLevel
			)
	VALUES  ( @IdCheck , -- IdCheck - int
				'DateOfIssue' , -- EditName - varchar(50)
				@SFecO , -- OriValue - varchar(100)
				@OriDateOfIssueScore , -- OriScore - int
				@SFecV , -- Value - varchar(100)
				@EditLevel  -- EditLevel - smallint
			);

	*/


	/* esta validacion se puso en [st_SaveChecks]
	--------------------------------------
	------ Validate Amount Value ------

	SET @EditLevel = 0;
	SELECT @MinAmountForHold = ISNULL(TRY_CAST(Value AS MONEY),0) FROM dbo.GlobalAttributes WHERE [Name]='AmountValue_ForHold';

	IF @MinAmountForHold > 0
	IF @Amount >= @MinAmountForHold
	BEGIN
		SET @EditLevel = 1;
		SET @IsEdited = 1;
	END;

	IF @EditLevel > 0
	INSERT INTO dbo.CheckEdits
			( IdCheck ,
				EditName ,
				OriValue ,
				OriScore ,
				Value ,
				EditLevel
			)
	VALUES  ( @IdCheck , -- IdCheck - int
				'Amount' , -- EditName - varchar(50)
				@OriAmount , -- OriValue - varchar(100)
				@OriAmountScore , -- OriScore - int
				@Amount , -- Value - varchar(100)
				@EditLevel  -- EditLevel - smallint
			);
	*/


END TRY
BEGIN CATCH
	--SET @HasError = 1
	--SET @Message =  dbo.GetMessageFromLenguajeResorces (@IsSpanish,96)
	DECLARE @ErrorMessage nvarchar(max)                                                                                             
	SELECT @ErrorMessage=ERROR_MESSAGE()                                             
	INSERT INTO ErrorLogForStoreProcedure(StoreProcedure,ErrorDate,ErrorMessage)VALUES('st_SaveCheckEdits',Getdate(),@ErrorMessage);
	THROW;
END CATCH;

