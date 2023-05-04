CREATE TABLE [Soporte].[CitiesToDelete] (
    [IdC]           BIGINT         NULL,
    [CityName]      NVARCHAR (MAX) NOT NULL,
    [CityO]         INT            NULL,
    [CityD]         INT            NOT NULL,
    [IdState]       INT            NOT NULL,
    [ReadyToDelete] INT            NOT NULL,
    [IsDeleted]     INT            NOT NULL
);

