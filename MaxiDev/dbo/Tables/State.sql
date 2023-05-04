CREATE TABLE [dbo].[State] (
    [IdState]            INT            IDENTITY (1, 1) NOT NULL,
    [StateName]          NVARCHAR (MAX) NOT NULL,
    [IdCountry]          INT            NOT NULL,
    [DateOfLastChange]   DATETIME       NOT NULL,
    [EnterByIdUser]      INT            NOT NULL,
    [StateCode]          VARCHAR (MAX)  NULL,
    [StateCodeBTS]       NVARCHAR (MAX) NULL,
    [StateCodeISO3166]   NVARCHAR (6)   NULL,
    [SendLicense]        BIT            NULL,
    [StateCodeTNC]       VARCHAR (50)   NULL,
    [StateCodeISO3166_2] VARCHAR (10)   NULL,
    CONSTRAINT [PK_State] PRIMARY KEY CLUSTERED ([IdState] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_State_Country] FOREIGN KEY ([IdCountry]) REFERENCES [dbo].[Country] ([IdCountry])
);

