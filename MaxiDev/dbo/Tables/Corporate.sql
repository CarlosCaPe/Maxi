CREATE TABLE [dbo].[Corporate] (
    [IdUserCorporate] INT           NOT NULL,
    [ZipCode]         VARCHAR (50)  NOT NULL,
    [State]           VARCHAR (200) NOT NULL,
    [City]            VARCHAR (200) NOT NULL,
    [Address]         VARCHAR (500) NOT NULL,
    [Phone]           VARCHAR (50)  NOT NULL,
    [Cellular]        VARCHAR (50)  NOT NULL,
    [Email]           VARCHAR (200) NOT NULL,
    [IdCounty]        INT           NULL,
    CONSTRAINT [PK_Corporate] PRIMARY KEY CLUSTERED ([IdUserCorporate] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Corporate_County] FOREIGN KEY ([IdCounty]) REFERENCES [dbo].[County] ([IdCounty]),
    CONSTRAINT [FK_Corporate_Users] FOREIGN KEY ([IdUserCorporate]) REFERENCES [dbo].[Users] ([IdUser])
);

