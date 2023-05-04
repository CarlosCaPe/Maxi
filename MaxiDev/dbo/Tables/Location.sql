CREATE TABLE [dbo].[Location] (
    [idLocation]   INT            IDENTITY (1, 1) NOT NULL,
    [idCountry]    INT            NULL,
    [idState]      INT            NULL,
    [idCity]       INT            NULL,
    [LocationName] VARCHAR (2000) NULL,
    [AL1]          VARCHAR (2000) NULL,
    [AL2]          VARCHAR (2000) NULL,
    [AL3]          VARCHAR (2000) NULL,
    CONSTRAINT [PK_Location] UNIQUE NONCLUSTERED ([idLocation] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_Location_idCountry_idState_idCity]
    ON [dbo].[Location]([idCountry] ASC, [idState] ASC, [idCity] ASC);

