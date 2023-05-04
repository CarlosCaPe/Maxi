CREATE PROCEDURE [dbo].[st_GetStatesByCountry] 
	@IdCountry INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT [IdState], [StateName], [IdCountry], [DateOfLastChange], [EnterByIdUser], [StateCode], [StateCodeBTS], [StateCodeISO3166], [SendLicense]
    FROM [dbo].[State] WITH(NOLOCK)
	WHERE [IdCountry] = @IdCountry
	ORDER BY StateName ASC
END