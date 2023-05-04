CREATE TABLE [Soporte].[StateToDelete] (
    [IdS]           BIGINT         NULL,
    [StateName]     NVARCHAR (MAX) NOT NULL,
    [StateO]        INT            NULL,
    [StateD]        INT            NOT NULL,
    [IdCountry]     INT            NOT NULL,
    [ReadyToDelete] INT            NOT NULL,
    [IsDeleted]     INT            NOT NULL
);

