CREATE TABLE [dbo].[FD_Enviroment] (
    [Id]            INT           IDENTITY (1, 1) NOT NULL,
    [Name]          VARCHAR (30)  NOT NULL,
    [BaseUrl]       VARCHAR (200) NOT NULL,
    [ApiKey]        VARCHAR (200) NOT NULL,
    [EmailConfigId] BIGINT        NOT NULL,
    [Priority]      INT           NOT NULL,
    CONSTRAINT [PK_FDEnviroment] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [CK_FDEnviroment_Priority] CHECK ([Priority]=(4) OR [Priority]=(3) OR [Priority]=(2) OR [Priority]=(1)),
    CONSTRAINT [UQ_FDEnviroment_Name] UNIQUE NONCLUSTERED ([Name] ASC)
);

