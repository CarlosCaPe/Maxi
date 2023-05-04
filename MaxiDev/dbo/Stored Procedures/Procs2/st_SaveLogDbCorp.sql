-- =============================================
-- Author:		<jresendiz>
-- Create date: <01/03/2019>
-- Description:	<Save Log DataBase>
-- =============================================
CREATE PROCEDURE [dbo].[st_SaveLogDbCorp] 
	@IdUser int,
	@Request nvarchar(max),
	@Response nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	INSERT INTO LogDbCorp
           (IdUser
           ,Request
           ,Response
           ,Date)
     VALUES
           (@IdUser, 
            @Request, 
            @Response, 
            GETDATE())
END

