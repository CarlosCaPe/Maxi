CREATE TABLE [MaxiMobile].[ApiKey] (
    [IdApiKey] INT           IDENTITY (1, 1) NOT NULL,
    [ApiKey]   NVARCHAR (50) NOT NULL,
    [Expire]   DATETIME      NULL,
    [IsValid]  BIT           DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_apikey] PRIMARY KEY CLUSTERED ([IdApiKey] ASC) WITH (FILLFACTOR = 90)
);

