Create Procedure MoneyAlert.st_SaveStoreProcedureUsage
(
    @Name nvarchar(max),
    @IdGeneric int
)
as
BEGIN TRY
    insert into MoneyAlert.StoreProcedureUsage
    values
    (@Name,getdate(),@IdGeneric)
END TRY
BEGIN CATCH
	INSERT INTO [MoneyAlert].[ErrorLogForStoreProcedure] ([StoreProcedure],[Line],[Message],[Number],[Severity],[State],[ErrorDate])
	VALUES (ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE(), ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), GETDATE())
END CATCH