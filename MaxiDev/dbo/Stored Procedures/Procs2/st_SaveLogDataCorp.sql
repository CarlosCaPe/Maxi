-- =============================================
-- Author:		<jresendiz>
-- Create date: <01/03/2019>
-- Description:	<Save Log Data>
-- =============================================
CREATE PROCEDURE [dbo].[st_SaveLogDataCorp] 
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

