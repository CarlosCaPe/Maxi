CREATE PROCEDURE [Corp].[st_SaveLogDataCorp] 
	@IdUser int,
	@Request nvarchar(max),
	@Response nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO LogDataCorp
           (IdUser,
            Request,
            Response,
            Date)
     VALUES
           (@IdUser, 
            @Request, 
            @Response, 
            GETDATE())
END

