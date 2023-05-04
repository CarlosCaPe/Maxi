CREATE TABLE [dbo].[SSISConfigMail] (
    [IdSSISConfigMail] BIGINT         IDENTITY (1, 1) NOT NULL,
    [Subject]          NVARCHAR (500) NOT NULL,
    [Body]             NVARCHAR (500) NOT NULL,
    [ServiceName]      NVARCHAR (500) NOT NULL,
    PRIMARY KEY CLUSTERED ([IdSSISConfigMail] ASC)
);

