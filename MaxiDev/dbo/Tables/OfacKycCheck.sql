CREATE TABLE [dbo].[OfacKycCheck] (
    [IdOfacKycCheck] INT            NOT NULL,
    [MinRange]       FLOAT (53)     NOT NULL,
    [MaxRange]       FLOAT (53)     NOT NULL,
    [Description]    NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_OfacKycCheck] PRIMARY KEY CLUSTERED ([IdOfacKycCheck] ASC)
);

