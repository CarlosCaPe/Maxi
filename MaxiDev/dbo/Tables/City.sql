CREATE TABLE [dbo].[City] (
    [IdCity]           INT            IDENTITY (1, 1) NOT NULL,
    [IdState]          INT            NOT NULL,
    [CityName]         NVARCHAR (MAX) NOT NULL,
    [DateOfLastChange] DATETIME       NOT NULL,
    [EnterByIdUser]    INT            NOT NULL,
    CONSTRAINT [PK_City] PRIMARY KEY CLUSTERED ([IdCity] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_City_State] FOREIGN KEY ([IdState]) REFERENCES [dbo].[State] ([IdState])
);


GO
CREATE NONCLUSTERED INDEX [ix_city_idstate_include_idcity]
    ON [dbo].[City]([IdState] ASC)
    INCLUDE([IdCity]);


GO
CREATE TRIGGER DeleteCitySearch
ON dbo.City
FOR DELETE
NOT FOR REPLICATION
AS
BEGIN
	SET NOCOUNT ON
	DELETE cs 
	FROM CitySearch cs
		JOIN DELETED d ON d.IdCity = cs.IdCity
END
GO
CREATE TRIGGER SyncCitySearch
ON dbo.City
AFTER INSERT, UPDATE
NOT FOR REPLICATION
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @Changes TABLE (IdCity INT)

	INSERT INTO @Changes
	SELECT
		i.IdCity
	FROM INSERTED i

	DECLARE @CurrentId INT

	WHILE EXISTS(SELECT 1 FROM @Changes)
	BEGIN
		SELECT TOP 1 @CurrentId = c.IdCity FROM @Changes c

		EXEC st_UpdateCitySearch @CurrentId

		DELETE FROM @Changes WHERE IdCity = @CurrentId
	END
END
