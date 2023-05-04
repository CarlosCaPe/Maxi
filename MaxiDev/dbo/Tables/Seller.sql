CREATE TABLE [dbo].[Seller] (
    [IdUserSeller]       INT            NOT NULL,
    [Zipcode]            VARCHAR (50)   NOT NULL,
    [State]              VARCHAR (200)  NOT NULL,
    [City]               VARCHAR (200)  NOT NULL,
    [Address]            VARCHAR (500)  NOT NULL,
    [Phone]              VARCHAR (50)   NOT NULL,
    [Cellular]           VARCHAR (50)   NOT NULL,
    [Email]              VARCHAR (200)  NOT NULL,
    [IdUserSellerParent] INT            NULL,
    [DeviceId]           NVARCHAR (100) NULL,
    [RegistrationId]     NVARCHAR (200) NULL,
    [DateOfLastAccess]   DATETIME       NULL,
    [IdCounty]           INT            NULL,
    CONSTRAINT [PK_Seller] PRIMARY KEY CLUSTERED ([IdUserSeller] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Seller_County] FOREIGN KEY ([IdCounty]) REFERENCES [dbo].[County] ([IdCounty]),
    CONSTRAINT [FK_Seller_Users] FOREIGN KEY ([IdUserSeller]) REFERENCES [dbo].[Users] ([IdUser])
);

