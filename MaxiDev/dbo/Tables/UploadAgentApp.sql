CREATE TABLE [dbo].[UploadAgentApp] (
    [IdUploadAgentApp] INT IDENTITY (1, 1) NOT NULL,
    [IdAgentApp]       INT NOT NULL,
    [HasNewImg]        BIT CONSTRAINT [DF_UploadAgentApp_HasNewImg] DEFAULT ((0)) NOT NULL,
    [IdUser]           INT NOT NULL,
    CONSTRAINT [PK_UploadAgentApp] PRIMARY KEY CLUSTERED ([IdUploadAgentApp] ASC),
    CONSTRAINT [FK_UploadAgentApp_AgentApplications] FOREIGN KEY ([IdAgentApp]) REFERENCES [dbo].[AgentApplications] ([IdAgentApplication]),
    CONSTRAINT [FK_UploadAgentApp_Users] FOREIGN KEY ([IdUser]) REFERENCES [dbo].[Users] ([IdUser])
);

