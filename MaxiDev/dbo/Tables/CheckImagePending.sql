CREATE TABLE [dbo].[CheckImagePending] (
    [IdcheckImagePending] INT            IDENTITY (1, 1) NOT NULL,
    [CreateDate]          DATETIME       NULL,
    [UserId]              INT            NULL,
    [Agent]               INT            NULL,
    [ProcessingDate]      DATETIME       NULL,
    [Path]                NVARCHAR (200) NULL
);

