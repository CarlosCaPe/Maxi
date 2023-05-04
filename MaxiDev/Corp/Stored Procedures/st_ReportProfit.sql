CREATE procedure [Corp].[st_ReportProfit]
(
@IdCountryCurrency int,
@StartDate datetime,
@EndDate datetime,
@IdUserSeller int,
@IdUserRequester int,
@State nvarchar(2) = null,
@Type int= null -- 1 All, 2 By Country
)
as          

	
BEGIN
--old
/*
exec [dbo].[st_ReportProfitV1]
		@IdCountryCurrency = @IdCountryCurrency,
		@StartDate = @StartDate,
		@EndDate = @EndDate,
		@IdUserSeller = @IdUserSeller,
		@IdUserRequester = @IdUserRequester,
		@State = @State
*/
	DECLARE @StartTime datetime = getdate()
	DECLARE @Time int

	exec [st_ReportProfitVCountry]        
			@IdCountryCurrency = @IdCountryCurrency,
			@StartDate = @StartDate,
			@EndDate = @EndDate,
			@IdUserSeller = @IdUserSeller,
			@IdUserRequester = @IdUserRequester,
			@State = @State,
			@Type = @Type

	SET @Time = DATEDIFF(SECOND, @StartTime, GETDATE())
	--IF @Time > 59
		INSERT INTO [Soporte].[InfoLogForStoreProcedure] ([StoreProcedure], [InfoDate], [InfoMessage]) VALUES('Corp.st_ReportProfit: @IdCountryCurrency = ' + CONVERT(VARCHAR, ISNULL(@IdCountryCurrency, 0)) + ', @StartDate = ' + CONVERT(VARCHAR, ISNULL(@StartDate, '1900-01-01 00:00:00.000'), 121) + ', @EndDate = ' + CONVERT(VARCHAR, ISNULL(@EndDate, '1900-01-01 00:00:00.000'), 121) + ', @IdUserSeller = ' + CONVERT(VARCHAR, ISNULL(@IdUserSeller, 0)) + ', @IdUserRequester = ' + CONVERT(VARCHAR, ISNULL(@IdUserRequester, 0)), GETDATE(), 'Validando ejecución de profit, time: ' + CONVERT(varchar, @Time))
--new

/*
exec [dbo].[st_ReportProfitV2]
		@IdCountryCurrency = @IdCountryCurrency,
		@StartDate = @StartDate,
		@EndDate = @EndDate,
		@IdUserSeller = @IdUserSeller,
		@IdUserRequester = @IdUserRequester,
		@State = @State,
        @Type = @Type

		*/
END

