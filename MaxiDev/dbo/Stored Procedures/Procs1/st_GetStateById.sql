CREATE PROCEDURE [dbo].[st_GetStateById] 
	@IdState INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT [IdState], [StateName], [IdCountry], [DateOfLastChange], [EnterByIdUser], [StateCode], [StateCodeBTS], [StateCodeISO3166], [SendLicense]
    FROM [dbo].[State] WITH(NOLOCK)
	WHERE [IdState] = @IdState
END


